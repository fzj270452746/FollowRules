//
//  MesinStatusPermainan.swift
//  FollowRules
//
//  Game State Machine - Refactored with Command Pattern & Functional Approach
//

import Foundation
import Combine

// MARK: - Mesin Status (State Machine) - Refactored Implementation
class MesinStatusPermainan {
    
    @Published private(set) var statusSekarang: StatusPermainan = .tidakDimulai
    
    private var grafTransisi: [StatusPermainan: Set<StatusPermainan>] = [:]
    private let validatorTransisi: ValidatorTransisiStatus
    private let pengeksekusiTransisi: PengeksekusiTransisiStatus
    
    init() {
        validatorTransisi = ValidatorTransisiStatus()
        pengeksekusiTransisi = PengeksekusiTransisiStatus()
        konfigurasiGrafTransisi()
    }
    
    func transisike(_ statusBaru: StatusPermainan) -> Bool {
        guard validatorTransisi.validasiTransisi(dari: statusSekarang, ke: statusBaru, menggunakan: grafTransisi) else {
            return false
        }
        
        pengeksekusiTransisi.eksekusiTransisi(dari: statusSekarang, ke: statusBaru) { [weak self] berhasil in
            if berhasil {
                self?.statusSekarang = statusBaru
            }
        }
        return true
    }
    
    func dapatTransisiKe(_ status: StatusPermainan) -> Bool {
        return validatorTransisi.validasiTransisi(dari: statusSekarang, ke: status, menggunakan: grafTransisi)
    }
    
    func reset() {
        statusSekarang = .tidakDimulai
    }
    
    private func konfigurasiGrafTransisi() {
        grafTransisi = [
            .tidakDimulai: [.siapMulai],
            .siapMulai: [.sedangBermain, .tidakDimulai],
            .sedangBermain: [.jeda, .menungguVerifikasi, .selesaiWaktuHabis],
            .jeda: [.sedangBermain, .tidakDimulai],
            .menungguVerifikasi: [.selesaiSukses, .selesaiGagal, .sedangBermain],
            .selesaiSukses: [.siapMulai, .tidakDimulai],
            .selesaiGagal: [.siapMulai, .tidakDimulai],
            .selesaiWaktuHabis: [.siapMulai, .tidakDimulai]
        ]
    }
}

// MARK: - Validator Transisi Status
class ValidatorTransisiStatus {
    func validasiTransisi(dari sumber: StatusPermainan, ke target: StatusPermainan, menggunakan graf: [StatusTransisi: Set<StatusTransisi>]) -> Bool {
        guard let statusDiizinkan = graf[sumber] else {
            return false
        }
        return statusDiizinkan.contains(target)
    }
}

// MARK: - Pengeksekusi Transisi Status
class PengeksekusiTransisiStatus {
    func eksekusiTransisi(dari sumber: StatusTransisi, ke target: StatusTransisi, selesai: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            selesai(true)
        }
    }
}

// MARK: - Typealias untuk Status
typealias StatusTransisi = StatusPermainan

// MARK: - Layanan Permainan (Game Service) - Refactored with Command Pattern
class LayananPermainan: ProtocolLayananPermainan {
    
    // MARK: - Published Properties
    private let statusSubject = PassthroughSubject<StatusPermainan, Never>()
    private let skorSubject = CurrentValueSubject<Int, Never>(0)
    private let tingkatSubject = CurrentValueSubject<Int, Never>(1)
    
    var penerbitStatusPermainan: AnyPublisher<StatusPermainan, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    var penerbitSkorSaatIni: AnyPublisher<Int, Never> {
        skorSubject.eraseToAnyPublisher()
    }
    
    var penerbitTingkatSaatIni: AnyPublisher<Int, Never> {
        tingkatSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let pabrikKartu: ProtocolPembuatKartu
    private let pabrikAturan: ProtocolPembuatAturan
    private let repositoriSkor: RepositoriSkor
    private let mesinStatus: MesinStatusPermainan
    private let pengelolaPerintah: PengelolaPerintahPermainan
    
    // MARK: - State
    private var konfigurasiSekarang: KonfigurasiPermainan?
    private var kartuSekarang: [EntitasKartu] = []
    private var aturanSekarang: EntitasAturan?
    private var kartuTerpilih: Set<UUID> = []
    private var waktuMulai: Date?
    private var waktuTersisa: TimeInterval = 0
    private var timerWaktu: Timer?
    private let pengelolaStatus: PengelolaStatusPermainan
    
    // MARK: - Initialization
    init(pabrikKartu: ProtocolPembuatKartu,
         pabrikAturan: ProtocolPembuatAturan,
         repositoriSkor: RepositoriSkor,
         mesinStatus: MesinStatusPermainan = MesinStatusPermainan()) {
        self.pabrikKartu = pabrikKartu
        self.pabrikAturan = pabrikAturan
        self.repositoriSkor = repositoriSkor
        self.mesinStatus = mesinStatus
        self.pengelolaPerintah = PengelolaPerintahPermainan(
            pabrikKartu: pabrikKartu,
            pabrikAturan: pabrikAturan,
            repositoriSkor: repositoriSkor
        )
        self.pengelolaStatus = PengelolaStatusPermainan()
        aturObservasiStatus()
    }
    
    // MARK: - Public Methods
    func inisialisasiPermainanBaru(denganKonfigurasi konfigurasi: KonfigurasiPermainan) {
        self.konfigurasiSekarang = konfigurasi
        
        pengelolaStatus.resetState()
        pengelolaStatus.updateSkor(0)
        pengelolaStatus.updateTingkat(1)
        kartuTerpilih.removeAll()
        
        if case .waktu = konfigurasi.mode {
            waktuTersisa = konfigurasi.durasiWaktu ?? 120
            mulaiTimerWaktu()
        }
        
        waktuMulai = Date()
        
        mesinStatus.transisike(.siapMulai)
        mesinStatus.transisike(.sedangBermain)
        statusSubject.send(mesinStatus.statusSekarang)
        
        muatTingkatBerikutnya()
    }
    
    func prosesAksiPemain(_ aksi: AksiPemain) -> HasilAksi {
        let konteks = buatKonteksPerintah()
        let perintah = pengelolaPerintah.buatPerintah(untukAksi: aksi, konteks: konteks)
        let hasil = perintah.eksekusi()
        
        // Terapkan perubahan state dari hasil perintah
        terapkanPerubahanState(dariHasil: hasil, untukAksi: aksi)
        
        return hasil
    }
    
    private func terapkanPerubahanState(dariHasil hasil: HasilAksi, untukAksi aksi: AksiPemain) {
        guard hasil.berhasil else { return }
        
        switch aksi {
        case .pilihKartu(let indeks):
            if let kartuTerpilihBaru = hasil.dataEfekSamping?["kartu_terpilih"] as? Set<UUID> {
                kartuTerpilih = kartuTerpilihBaru
            }
        case .batalkanPilihan(let indeks):
            if let kartuTerpilihBaru = hasil.dataEfekSamping?["kartu_terpilih"] as? Set<UUID> {
                kartuTerpilih = kartuTerpilihBaru
            }
        case .verifikasiJawaban:
            if hasil.berhasil {
                mesinStatus.transisike(.menungguVerifikasi)
            }
            if hasil.statusBaru == .selesaiSukses {
                mesinStatus.transisike(.selesaiSukses)
            } else if hasil.statusBaru == .selesaiGagal {
                mesinStatus.transisike(.selesaiGagal)
            }
        case .lanjutkanTingkatBerikutnya:
            if let tingkatBaru = hasil.dataEfekSamping?["new_level"] as? Int {
                tingkatSubject.send(tingkatBaru)
            }
            if let skorBaru = hasil.dataEfekSamping?["new_score"] as? Int {
                skorSubject.send(skorBaru)
            }
            mesinStatus.transisike(.sedangBermain)
            muatTingkatBerikutnya()
        case .jedakanPermainan:
            hentikanTimerWaktu()
            mesinStatus.transisike(.jeda)
        case .lanjutkanPermainan:
            if case .waktu = konfigurasiSekarang?.mode {
                mulaiTimerWaktu()
            }
            mesinStatus.transisike(.sedangBermain)
        case .keluarPermainan:
            hentikanTimerWaktu()
            setelUlangPermainan()
        default:
            break
        }
        
        statusSubject.send(mesinStatus.statusSekarang)
    }
    
    func dapatkanStatusSaatIni() -> SnapshotStatusPermainan {
        return SnapshotStatusPermainan(
            status: mesinStatus.statusSekarang,
            tingkatSekarang: tingkatSubject.value,
            skorSekarang: skorSubject.value,
            waktuTersisa: waktuTersisa > 0 ? waktuTersisa : nil,
            kartuSekarang: kartuSekarang,
            aturanSekarang: aturanSekarang,
            kartuTerpilih: kartuTerpilih,
            metaData: [:]
        )
    }
    
    func setelUlangPermainan() {
        hentikanTimerWaktu()
        mesinStatus.reset()
        konfigurasiSekarang = nil
        kartuSekarang.removeAll()
        aturanSekarang = nil
        kartuTerpilih.removeAll()
        pengelolaStatus.resetState()
        pengelolaStatus.updateSkor(0)
        pengelolaStatus.updateTingkat(1)
        skorSubject.send(0)
        tingkatSubject.send(1)
    }
    
    // MARK: - Private Methods
    
    private func aturObservasiStatus() {
        mesinStatus.$statusSekarang
            .sink { [weak self] status in
                self?.statusSubject.send(status)
            }
            .store(in: &pengelolaStatus.cancellables)
    }
    
    private func buatKonteksPerintah() -> KonteksPerintahPermainan {
        return KonteksPerintahPermainan(
            konfigurasi: konfigurasiSekarang,
            kartuSekarang: kartuSekarang,
            aturanSekarang: aturanSekarang,
            kartuTerpilih: kartuTerpilih,
            tingkatSekarang: tingkatSubject.value,
            skorSekarang: skorSubject.value,
            waktuMulai: waktuMulai,
            waktuTersisa: waktuTersisa
        )
    }
    
    private func muatTingkatBerikutnya() {
        guard let konfigurasi = konfigurasiSekarang else { return }
        
        kartuTerpilih.removeAll()
        
        let jumlahKartu = hitungJumlahKartu(dariKonfigurasi: konfigurasi)
        let strategiPemilihan = buatStrategiPemilihan(dariKonfigurasi: konfigurasi)
        
        kartuSekarang = pabrikKartu.buatKumpulanKartu(jumlah: jumlahKartu, strategiPemilihan: strategiPemilihan)
        
        let konteks = KonteksPermainan(
            tingkatSekarang: tingkatSubject.value,
            jumlahKartu: jumlahKartu,
            kartuTersedia: kartuSekarang,
            riwayatAturan: [],
            tingkatKompleksitas: hitungKompleksitas()
        )
        
        aturanSekarang = pabrikAturan.buatAturanBaru(untukKonteks: konteks)
        
        if let aturan = aturanSekarang, !pabrikAturan.validasiAturan(aturan, terhadapKartu: kartuSekarang) {
            muatTingkatBerikutnya()
        }
    }
    
    private func hitungJumlahKartu(dariKonfigurasi konfigurasi: KonfigurasiPermainan) -> Int {
        if let kesulitan = konfigurasi.tingkatKesulitan {
            return kesulitan.rawValue * kesulitan.rawValue
        }
        
        let tingkatSekarang = tingkatSubject.value
        let skorSekarang = skorSubject.value
        
        if skorSekarang >= 50 {
            return 25
        } else if skorSekarang >= 20 {
            return 16
        } else {
            return 9
        }
    }
    
    private func buatStrategiPemilihan(dariKonfigurasi konfigurasi: KonfigurasiPermainan) -> StrategiPemilihanKartu {
        if let kesulitan = konfigurasi.tingkatKesulitan {
            return .strategiDinamis(tingkatKesulitan: kesulitan)
        }
        return .acak
    }
    
    private func hitungKompleksitas() -> Int {
        let tingkat = tingkatSubject.value
        return min((tingkat - 1) / 3 + 1, 4)
    }
    
    // MARK: - Timer
    
    private func mulaiTimerWaktu() {
        hentikanTimerWaktu()
        
        timerWaktu = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.waktuTersisa -= 1
            
            if self.waktuTersisa <= 0 {
                self.hentikanTimerWaktu()
                self.mesinStatus.transisike(.selesaiWaktuHabis)
                self.simpanSkorModeWaktu()
            }
        }
    }
    
    private func hentikanTimerWaktu() {
        timerWaktu?.invalidate()
        timerWaktu = nil
    }
    
    private func simpanSkorModeWaktu() {
        let entri = EntriSkor(
            mode: .waktu,
            skor: skorSubject.value,
            tingkatDicapai: tingkatSubject.value,
            durasiPermainan: Date().timeIntervalSince(waktuMulai ?? Date())
        )
        try? repositoriSkor.simpanSkor(entri)
    }
}

// MARK: - Pengelola Perintah Permainan (Command Manager)
class PengelolaPerintahPermainan {
    private let pabrikKartu: ProtocolPembuatKartu
    private let pabrikAturan: ProtocolPembuatAturan
    private let repositoriSkor: RepositoriSkor
    
    init(pabrikKartu: ProtocolPembuatKartu,
         pabrikAturan: ProtocolPembuatAturan,
         repositoriSkor: RepositoriSkor) {
        self.pabrikKartu = pabrikKartu
        self.pabrikAturan = pabrikAturan
        self.repositoriSkor = repositoriSkor
    }
    
    func buatPerintah(untukAksi aksi: AksiPemain, konteks: KonteksPerintahPermainan) -> PerintahPermainan {
        switch aksi {
        case .mulaiPermainan:
            return PerintahMulaiPermainan(konteks: konteks)
        case .pilihKartu(let indeks):
            return PerintahPilihKartu(indeks: indeks, konteks: konteks)
        case .batalkanPilihan(let indeks):
            return PerintahBatalkanPilihan(indeks: indeks, konteks: konteks)
        case .verifikasiJawaban:
            return PerintahVerifikasiJawaban(konteks: konteks, pabrikAturan: pabrikAturan)
        case .lanjutkanTingkatBerikutnya:
            return PerintahLanjutkanTingkat(konteks: konteks, repositoriSkor: repositoriSkor, pabrikKartu: pabrikKartu, pabrikAturan: pabrikAturan)
        case .jedakanPermainan:
            return PerintahJedaPermainan(konteks: konteks)
        case .lanjutkanPermainan:
            return PerintahLanjutkanPermainan(konteks: konteks)
        case .keluarPermainan:
            return PerintahKeluarPermainan(konteks: konteks)
        }
    }
}

// MARK: - Protocol Perintah
protocol PerintahPermainan {
    func eksekusi() -> HasilAksi
}

// MARK: - Konteks Perintah
struct KonteksPerintahPermainan {
    let konfigurasi: KonfigurasiPermainan?
    let kartuSekarang: [EntitasKartu]
    let aturanSekarang: EntitasAturan?
    let kartuTerpilih: Set<UUID>
    let tingkatSekarang: Int
    let skorSekarang: Int
    let waktuMulai: Date?
    let waktuTersisa: TimeInterval
}

// MARK: - Implementasi Perintah
class PerintahMulaiPermainan: PerintahPermainan {
    private let konteks: KonteksPerintahPermainan
    
    init(konteks: KonteksPerintahPermainan) {
        self.konteks = konteks
    }
    
    func eksekusi() -> HasilAksi {
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .sedangBermain, dataEfekSamping: nil)
    }
}

class PerintahPilihKartu: PerintahPermainan {
    private let indeks: Int
    private let konteks: KonteksPerintahPermainan
    
    init(indeks: Int, konteks: KonteksPerintahPermainan) {
        self.indeks = indeks
        self.konteks = konteks
    }
    
    func eksekusi() -> HasilAksi {
        guard indeks < konteks.kartuSekarang.count else {
            return HasilAksi(berhasil: false, pesan: "Invalid card index", statusBaru: .sedangBermain, dataEfekSamping: nil)
        }
        
        let kartu = konteks.kartuSekarang[indeks]
        var kartuTerpilihBaru = konteks.kartuTerpilih
        kartuTerpilihBaru.insert(kartu.id)
        
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .sedangBermain, dataEfekSamping: ["card_id": kartu.id, "kartu_terpilih": kartuTerpilihBaru])
    }
}

class PerintahBatalkanPilihan: PerintahPermainan {
    private let indeks: Int
    private let konteks: KonteksPerintahPermainan
    
    init(indeks: Int, konteks: KonteksPerintahPermainan) {
        self.indeks = indeks
        self.konteks = konteks
    }
    
    func eksekusi() -> HasilAksi {
        guard indeks < konteks.kartuSekarang.count else {
            return HasilAksi(berhasil: false, pesan: "Invalid card index", statusBaru: .sedangBermain, dataEfekSamping: nil)
        }
        
        let kartu = konteks.kartuSekarang[indeks]
        var kartuTerpilihBaru = konteks.kartuTerpilih
        kartuTerpilihBaru.remove(kartu.id)
        
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .sedangBermain, dataEfekSamping: ["card_id": kartu.id, "kartu_terpilih": kartuTerpilihBaru])
    }
}

class PerintahVerifikasiJawaban: PerintahPermainan {
    private let konteks: KonteksPerintahPermainan
    private let pabrikAturan: ProtocolPembuatAturan
    
    init(konteks: KonteksPerintahPermainan, pabrikAturan: ProtocolPembuatAturan) {
        self.konteks = konteks
        self.pabrikAturan = pabrikAturan
    }
    
    func eksekusi() -> HasilAksi {
        guard let aturan = konteks.aturanSekarang else {
            return HasilAksi(berhasil: false, pesan: "No rule set", statusBaru: .sedangBermain, dataEfekSamping: nil)
        }
        
        let validator = ValidatorJawaban()
        let hasil = validator.validasiJawaban(
            kartu: konteks.kartuSekarang,
            aturan: aturan,
            kartuTerpilih: konteks.kartuTerpilih
        )
        
        if hasil.berhasil {
            return HasilAksi(berhasil: true, pesan: "Correct!", statusBaru: .selesaiSukses, dataEfekSamping: nil)
        } else {
            return HasilAksi(berhasil: false, pesan: hasil.pesanKesalahan, statusBaru: .selesaiGagal, dataEfekSamping: nil)
        }
    }
}

class PerintahLanjutkanTingkat: PerintahPermainan {
    private let konteks: KonteksPerintahPermainan
    private let repositoriSkor: RepositoriSkor
    private let pabrikKartu: ProtocolPembuatKartu
    private let pabrikAturan: ProtocolPembuatAturan
    
    init(konteks: KonteksPerintahPermainan, repositoriSkor: RepositoriSkor, pabrikKartu: ProtocolPembuatKartu, pabrikAturan: ProtocolPembuatAturan) {
        self.konteks = konteks
        self.repositoriSkor = repositoriSkor
        self.pabrikKartu = pabrikKartu
        self.pabrikAturan = pabrikAturan
    }
    
    func eksekusi() -> HasilAksi {
        var skorBaru = konteks.skorSekarang
        var tingkatBaru = konteks.tingkatSekarang + 1
        
        // 增加分数 - 根据游戏模式
        if case .waktu = konteks.konfigurasi?.mode {
            // 时间模式：每完成一关+10分
            skorBaru += 10
        } else if case .tantangan = konteks.konfigurasi?.mode {
            // 挑战模式：根据关卡难度和当前关卡增加分数
            // 基础分数：每关+5分
            var poinTambahan = 5
            
            // 根据难度加成
            if let kesulitan = konteks.konfigurasi?.tingkatKesulitan {
                switch kesulitan {
                case .mudah: poinTambahan += 0      // 3x3: +5分
                case .sedang: poinTambahan += 5     // 4x4: +10分
                case .sulit: poinTambahan += 10     // 5x5: +15分
                case .pakar: poinTambahan += 15     // 6x6: +20分
                }
            }
            
            // 根据关卡数加成（关卡越高，分数越多）
            let bonusTingkat = min(tingkatBaru / 5, 10) // 每5关+1分，最高+10分
            poinTambahan += bonusTingkat
            
            skorBaru += poinTambahan
        }
        
        // 保存分数记录
        if case .tantangan = konteks.konfigurasi?.mode {
            let entri = EntriSkor(
                mode: .tantangan,
                skor: tingkatBaru,
                tingkatDicapai: tingkatBaru,
                durasiPermainan: Date().timeIntervalSince(konteks.waktuMulai ?? Date())
            )
            try? repositoriSkor.simpanSkor(entri)
        }
        
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .sedangBermain, dataEfekSamping: ["new_level": tingkatBaru, "new_score": skorBaru])
    }
}

class PerintahJedaPermainan: PerintahPermainan {
    private let konteks: KonteksPerintahPermainan
    
    init(konteks: KonteksPerintahPermainan) {
        self.konteks = konteks
    }
    
    func eksekusi() -> HasilAksi {
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .jeda, dataEfekSamping: nil)
    }
}

class PerintahLanjutkanPermainan: PerintahPermainan {
    private let konteks: KonteksPerintahPermainan
    
    init(konteks: KonteksPerintahPermainan) {
        self.konteks = konteks
    }
    
    func eksekusi() -> HasilAksi {
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .sedangBermain, dataEfekSamping: nil)
    }
}

class PerintahKeluarPermainan: PerintahPermainan {
    private let konteks: KonteksPerintahPermainan
    
    init(konteks: KonteksPerintahPermainan) {
        self.konteks = konteks
    }
    
    func eksekusi() -> HasilAksi {
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .tidakDimulai, dataEfekSamping: nil)
    }
}

// MARK: - Validator Jawaban
class ValidatorJawaban {
    struct HasilValidasi {
        let berhasil: Bool
        let pesanKesalahan: String?
    }
    
    func validasiJawaban(kartu: [EntitasKartu], aturan: EntitasAturan, kartuTerpilih: Set<UUID>) -> HasilValidasi {
        var kesalahanPertama: String?
        
        for kartuItem in kartu {
            let harusDipilih = aturan.kriteriaPemilihan(kartuItem)
            let sudahDipilih = kartuTerpilih.contains(kartuItem.id)
            
            if harusDipilih != sudahDipilih {
                if kesalahanPertama == nil {
                    if harusDipilih {
                        kesalahanPertama = "You missed: \(kartuItem.deskripsiLengkap)"
                    } else {
                        kesalahanPertama = "Wrong: \(kartuItem.deskripsiLengkap) should not be removed"
                    }
                }
            }
        }
        
        if let kesalahan = kesalahanPertama {
            return HasilValidasi(berhasil: false, pesanKesalahan: kesalahan)
        }
        
        return HasilValidasi(berhasil: true, pesanKesalahan: nil)
    }
}

// MARK: - Pengelola Status Permainan
class PengelolaStatusPermainan {
    var cancellables = Set<AnyCancellable>()
    
    private var skorInternal: Int = 0
    private var tingkatInternal: Int = 1
    
    func updateSkor(_ nilai: Int) {
        skorInternal = nilai
    }
    
    func updateTingkat(_ nilai: Int) {
        tingkatInternal = nilai
    }
    
    func resetState() {
        skorInternal = 0
        tingkatInternal = 1
    }
}

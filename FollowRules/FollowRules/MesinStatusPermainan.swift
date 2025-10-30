//
//  MesinStatusPermainan.swift
//  FollowRules
//
//  Game State Machine
//

import Foundation
import Combine

// MARK: - Mesin Status (State Machine)
class MesinStatusPermainan {
    
    @Published private(set) var statusSekarang: StatusPermainan = .tidakDimulai
    private var transisiDiizinkan: [StatusPermainan: [StatusPermainan]] = [:]
    
    init() {
        konfigurasiTransisiStatus()
    }
    
    func transisike(_ statusBaru: StatusPermainan) -> Bool {
        guard dapatTransisiKe(statusBaru) else {
            return false
        }
        
        statusSekarang = statusBaru
        return true
    }
    
    func dapatTransisiKe(_ status: StatusPermainan) -> Bool {
        guard let statusDiizinkan = transisiDiizinkan[statusSekarang] else {
            return false
        }
        return statusDiizinkan.contains(where: { String(describing: $0) == String(describing: status) })
    }
    
    func reset() {
        statusSekarang = .tidakDimulai
    }
    
    private func konfigurasiTransisiStatus() {
        transisiDiizinkan = [
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

// MARK: - Layanan Permainan (Game Service)
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
    
    // MARK: - State
    private var konfigurasiSekarang: KonfigurasiPermainan?
    private var kartuSekarang: [EntitasKartu] = []
    private var aturanSekarang: EntitasAturan?
    private var kartuTerpilih: Set<UUID> = []
    private var waktuMulai: Date?
    private var waktuTersisa: TimeInterval = 0
    private var timerWaktu: Timer?
    
    // MARK: - Initialization
    init(pabrikKartu: ProtocolPembuatKartu,
         pabrikAturan: ProtocolPembuatAturan,
         repositoriSkor: RepositoriSkor,
         mesinStatus: MesinStatusPermainan = MesinStatusPermainan()) {
        self.pabrikKartu = pabrikKartu
        self.pabrikAturan = pabrikAturan
        self.repositoriSkor = repositoriSkor
        self.mesinStatus = mesinStatus
    }
    
    // MARK: - Public Methods
    func inisialisasiPermainanBaru(denganKonfigurasi konfigurasi: KonfigurasiPermainan) {
        self.konfigurasiSekarang = konfigurasi
        
        // Reset state
        skorSubject.send(0)
        tingkatSubject.send(1)
        kartuTerpilih.removeAll()
        
        // Konfigurasi waktu jika mode waktu
        if case .waktu = konfigurasi.mode {
            waktuTersisa = konfigurasi.durasiWaktu ?? 120
            mulaiTimerWaktu()
        }
        
        waktuMulai = Date()
        
        // Transisi status
        mesinStatus.transisike(.siapMulai)
        mesinStatus.transisike(.sedangBermain)
        
        // Muat tingkat pertama
        muatTingkatBerikutnya()
    }
    
    func prosesAksiPemain(_ aksi: AksiPemain) -> HasilAksi {
        switch aksi {
        case .mulaiPermainan:
            return prosesAksiMulai()
        case .pilihKartu(let indeks):
            return prosesAksiPilihKartu(indeks: indeks)
        case .batalkanPilihan(let indeks):
            return prosesAksiBatalkanPilihan(indeks: indeks)
        case .verifikasiJawaban:
            return prosesAksiVerifikasi()
        case .lanjutkanTingkatBerikutnya:
            return prosesAksiLanjutkanTingkat()
        case .jedakanPermainan:
            return prosesAksiJeda()
        case .lanjutkanPermainan:
            return prosesAksiLanjutkan()
        case .keluarPermainan:
            return prosesAksiKeluar()
        }
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
        skorSubject.send(0)
        tingkatSubject.send(1)
    }
    
    // MARK: - Private Methods
    
    private func muatTingkatBerikutnya() {
        guard let konfigurasi = konfigurasiSekarang else { return }
        
        kartuTerpilih.removeAll()
        
        // Tentukan jumlah kartu berdasarkan kesulitan
        let jumlahKartu: Int
        if let kesulitan = konfigurasi.tingkatKesulitan {
            jumlahKartu = kesulitan.rawValue * kesulitan.rawValue
        } else {
            // Mode waktu dengan kesulitan dinamis
            let tingkatSekarang = tingkatSubject.value
            if skorSubject.value >= 50 {
                jumlahKartu = 25
            } else if skorSubject.value >= 20 {
                jumlahKartu = 16
            } else {
                jumlahKartu = 9
            }
        }
        
        // Buat kartu
        let strategiPemilihan: StrategiPemilihanKartu
        if let kesulitan = konfigurasi.tingkatKesulitan {
            strategiPemilihan = .strategiDinamis(tingkatKesulitan: kesulitan)
        } else {
            strategiPemilihan = .acak
        }
        
        kartuSekarang = pabrikKartu.buatKumpulanKartu(jumlah: jumlahKartu, strategiPemilihan: strategiPemilihan)
        
        // Buat aturan
        let konteks = KonteksPermainan(
            tingkatSekarang: tingkatSubject.value,
            jumlahKartu: jumlahKartu,
            kartuTersedia: kartuSekarang,
            riwayatAturan: [],
            tingkatKompleksitas: hitungKompleksitas()
        )
        
        aturanSekarang = pabrikAturan.buatAturanBaru(untukKonteks: konteks)
        
        // Validasi aturan
        if let aturan = aturanSekarang, !pabrikAturan.validasiAturan(aturan, terhadapKartu: kartuSekarang) {
            // Jika tidak valid, coba lagi
            muatTingkatBerikutnya()
        }
    }
    
    private func hitungKompleksitas() -> Int {
        let tingkat = tingkatSubject.value
        return min((tingkat - 1) / 3 + 1, 4)
    }
    
    private func prosesAksiMulai() -> HasilAksi {
        return HasilAksi(
            berhasil: true,
            pesan: nil,
            statusBaru: mesinStatus.statusSekarang,
            dataEfekSamping: nil
        )
    }
    
    private func prosesAksiPilihKartu(indeks: Int) -> HasilAksi {
        guard indeks < kartuSekarang.count else {
            return HasilAksi(berhasil: false, pesan: "Invalid card index", statusBaru: mesinStatus.statusSekarang, dataEfekSamping: nil)
        }
        
        let kartu = kartuSekarang[indeks]
        kartuTerpilih.insert(kartu.id)
        
        return HasilAksi(
            berhasil: true,
            pesan: nil,
            statusBaru: mesinStatus.statusSekarang,
            dataEfekSamping: ["card_id": kartu.id]
        )
    }
    
    private func prosesAksiBatalkanPilihan(indeks: Int) -> HasilAksi {
        guard indeks < kartuSekarang.count else {
            return HasilAksi(berhasil: false, pesan: "Invalid card index", statusBaru: mesinStatus.statusSekarang, dataEfekSamping: nil)
        }
        
        let kartu = kartuSekarang[indeks]
        kartuTerpilih.remove(kartu.id)
        
        return HasilAksi(
            berhasil: true,
            pesan: nil,
            statusBaru: mesinStatus.statusSekarang,
            dataEfekSamping: ["card_id": kartu.id]
        )
    }
    
    private func prosesAksiVerifikasi() -> HasilAksi {
        guard let aturan = aturanSekarang else {
            return HasilAksi(berhasil: false, pesan: "No rule set", statusBaru: mesinStatus.statusSekarang, dataEfekSamping: nil)
        }
        
        mesinStatus.transisike(.menungguVerifikasi)
        
        // Periksa setiap kartu
        var benar = true
        var pesanKesalahan: String?
        
        for kartu in kartuSekarang {
            let harusDipilih = aturan.kriteriaPemilihan(kartu)
            let sudahDipilih = kartuTerpilih.contains(kartu.id)
            
            if harusDipilih != sudahDipilih {
                benar = false
                if harusDipilih {
                    pesanKesalahan = "You missed: \(kartu.deskripsiLengkap)"
                } else {
                    pesanKesalahan = "Wrong: \(kartu.deskripsiLengkap) should not be removed"
                }
                break
            }
        }
        
        if benar {
            mesinStatus.transisike(.selesaiSukses)
            return HasilAksi(
                berhasil: true,
                pesan: "Correct!",
                statusBaru: mesinStatus.statusSekarang,
                dataEfekSamping: nil
            )
        } else {
            mesinStatus.transisike(.selesaiGagal)
            return HasilAksi(
                berhasil: false,
                pesan: pesanKesalahan,
                statusBaru: mesinStatus.statusSekarang,
                dataEfekSamping: nil
            )
        }
    }
    
    private func prosesAksiLanjutkanTingkat() -> HasilAksi {
        // Update skor
        if case .waktu = konfigurasiSekarang?.mode {
            let skorBaru = skorSubject.value + 10
            skorSubject.send(skorBaru)
        }
        
        // Update tingkat
        let tingkatBaru = tingkatSubject.value + 1
        tingkatSubject.send(tingkatBaru)
        
        // Simpan skor jika mode tantangan
        if case .tantangan = konfigurasiSekarang?.mode {
            let entri = EntriSkor(
                mode: .tantangan,
                skor: tingkatBaru,
                tingkatDicapai: tingkatBaru,
                durasiPermainan: Date().timeIntervalSince(waktuMulai ?? Date())
            )
            try? repositoriSkor.simpanSkor(entri)
        }
        
        // Muat tingkat berikutnya
        mesinStatus.transisike(.sedangBermain)
        muatTingkatBerikutnya()
        
        return HasilAksi(
            berhasil: true,
            pesan: nil,
            statusBaru: mesinStatus.statusSekarang,
            dataEfekSamping: ["new_level": tingkatBaru]
        )
    }
    
    private func prosesAksiJeda() -> HasilAksi {
        hentikanTimerWaktu()
        mesinStatus.transisike(.jeda)
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: mesinStatus.statusSekarang, dataEfekSamping: nil)
    }
    
    private func prosesAksiLanjutkan() -> HasilAksi {
        if case .waktu = konfigurasiSekarang?.mode {
            mulaiTimerWaktu()
        }
        mesinStatus.transisike(.sedangBermain)
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: mesinStatus.statusSekarang, dataEfekSamping: nil)
    }
    
    private func prosesAksiKeluar() -> HasilAksi {
        hentikanTimerWaktu()
        setelUlangPermainan()
        return HasilAksi(berhasil: true, pesan: nil, statusBaru: .tidakDimulai, dataEfekSamping: nil)
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


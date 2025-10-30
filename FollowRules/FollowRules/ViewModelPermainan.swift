//
//  ViewModelPermainan.swift
//  FollowRules
//
//  Game Screen ViewModel - Refactored with Functional Reactive Programming & Composition
//

import Foundation
import Combine
import UIKit

// MARK: - ViewModel Permainan (Game ViewModel) - Refactored Implementation
class ViewModelPermainan: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var statusPermainan: StatusPermainan = .tidakDimulai
    @Published private(set) var tingkatSekarang: Int = 1
    @Published private(set) var skorSekarang: Int = 0
    @Published private(set) var waktuTersisa: TimeInterval? = nil
    @Published private(set) var kartuSekarang: [EntitasKartu] = []
    @Published private(set) var aturanSekarang: String = ""
    @Published private(set) var kartuTerpilih: Set<UUID> = []
    @Published private(set) var ukuranKisi: Int = 3
    @Published private(set) var pesanFeedback: String?
    @Published private(set) var jenisAnimasi: JenisAnimasi?
    
    // MARK: - Dependencies
    private let layananPermainan: ProtocolLayananPermainan
    private let koordinatorAnimasi: ProtocolKoordinatorAnimasi
    private let konfigurasi: KonfigurasiPermainan
    
    private var cancellables = Set<AnyCancellable>()
    private let pengelolaTimer: PengelolaTimerPermainan
    private let komposerStatus: KomposerStatusPermainan
    
    // MARK: - Initialization
    init(layananPermainan: ProtocolLayananPermainan,
         koordinatorAnimasi: ProtocolKoordinatorAnimasi,
         konfigurasi: KonfigurasiPermainan) {
        self.layananPermainan = layananPermainan
        self.koordinatorAnimasi = koordinatorAnimasi
        self.konfigurasi = konfigurasi
        self.pengelolaTimer = PengelolaTimerPermainan()
        self.komposerStatus = KomposerStatusPermainan()
        
        konfigurasBindings()
        inisialisasiPermainan()
    }
    
    // MARK: - Public Methods
    
    func tanganiKetukanKartu(pada indeks: Int) {
        guard indeks < kartuSekarang.count else { return }
        
        let kartu = kartuSekarang[indeks]
        let sudahTerpilih = kartuTerpilih.contains(kartu.id)
        
        let aksi: AksiPemain = sudahTerpilih ? .batalkanPilihan(indeks: indeks) : .pilihKartu(indeks: indeks)
        let hasil = layananPermainan.prosesAksiPemain(aksi)
        
        if hasil.berhasil {
            perbaruiStatusDariLayanan()
            jenisAnimasi = .pilihanKartu
        }
    }
    
    func verifikasiJawaban(penyelesaian: @escaping (Bool, String?) -> Void) {
        let hasil = layananPermainan.prosesAksiPemain(.verifikasiJawaban)
        perbaruiStatusDariLayanan()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            penyelesaian(hasil.berhasil, hasil.pesan)
        }
    }
    
    func lanjutkanTingkatBerikutnya() {
        _ = layananPermainan.prosesAksiPemain(.lanjutkanTingkatBerikutnya)
        perbaruiStatusDariLayanan()
        jenisAnimasi = .transisiTingkat
    }
    
    func jedakanPermainan() {
        _ = layananPermainan.prosesAksiPemain(.jedakanPermainan)
        perbaruiStatusDariLayanan()
    }
    
    func lanjutkanPermainan() {
        _ = layananPermainan.prosesAksiPemain(.lanjutkanPermainan)
        perbaruiStatusDariLayanan()
        mulaiTimerWaktuJikaDiperlukan()
    }
    
    func keluarPermainan() {
        pengelolaTimer.hentikan()
        _ = layananPermainan.prosesAksiPemain(.keluarPermainan)
    }
    
    func dapatkanWarnaLatar() -> UIColor {
        return TemaWarnaTinta.warnaLatarUtama
    }
    
    func dapatkanWarnaHeader() -> UIColor {
        return TemaWarnaTinta.warnaTintaHitam
    }
    
    // MARK: - Private Methods
    
    private func konfigurasBindings() {
        let transformasiStatus = komposerStatus.buatTransformasiStatus()
        
        layananPermainan.penerbitStatusPermainan
            .receive(on: DispatchQueue.main)
            .map(transformasiStatus)
            .sink { [weak self] status in
                self?.statusPermainan = status
            }
            .store(in: &cancellables)
        
        layananPermainan.penerbitSkorSaatIni
            .receive(on: DispatchQueue.main)
            .sink { [weak self] skor in
                self?.skorSekarang = skor
            }
            .store(in: &cancellables)
        
        layananPermainan.penerbitTingkatSaatIni
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tingkat in
                self?.tingkatSekarang = tingkat
                self?.perbaruiUkuranKisi()
            }
            .store(in: &cancellables)
    }
    
    private func inisialisasiPermainan() {
        layananPermainan.inisialisasiPermainanBaru(denganKonfigurasi: konfigurasi)
        perbaruiStatusDariLayanan()
        perbaruiUkuranKisi()
        
        if case .waktu = konfigurasi.mode {
            mulaiTimerWaktuJikaDiperlukan()
        }
    }
    
    private func perbaruiStatusDariLayanan() {
        let snapshot = layananPermainan.dapatkanStatusSaatIni()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.statusPermainan = snapshot.status
            self.tingkatSekarang = snapshot.tingkatSekarang
            self.skorSekarang = snapshot.skorSekarang
            self.waktuTersisa = snapshot.waktuTersisa
            self.kartuSekarang = snapshot.kartuSekarang
            self.aturanSekarang = snapshot.aturanSekarang?.deskripsiTampilan ?? ""
            self.kartuTerpilih = snapshot.kartuTerpilih
        }
    }
    
    private func perbaruiUkuranKisi() {
        let kalkulatorUkuran = KalkulatorUkuranKisi(konfigurasi: konfigurasi)
        ukuranKisi = kalkulatorUkuran.hitung(tingkatSekarang: tingkatSekarang, skorSekarang: skorSekarang)
    }
    
    private func mulaiTimerWaktuJikaDiperlukan() {
        guard case .waktu = konfigurasi.mode else { return }
        
        pengelolaTimer.hentikan()
        
        pengelolaTimer.mulai(durasi: waktuTersisa ?? 120) { [weak self] waktuTersisa in
            guard let self = self else { return }
            
            self.waktuTersisa = waktuTersisa
            
            if waktuTersisa <= 10 {
                self.jenisAnimasi = .peringatanWaktu
            }
        }
    }
    
    deinit {
        pengelolaTimer.hentikan()
    }
}

// MARK: - Komposer Status Permainan
class KomposerStatusPermainan {
    func buatTransformasiStatus() -> (StatusPermainan) -> StatusPermainan {
        return { status in
            return status
        }
    }
}

// MARK: - Pengelola Timer Permainan
class PengelolaTimerPermainan {
    private var timerPublisher: AnyCancellable?
    private var callbackWaktu: ((TimeInterval) -> Void)?
    private var waktuTersisaInternal: TimeInterval = 0
    
    func mulai(durasi: TimeInterval, callback: @escaping (TimeInterval) -> Void) {
        hentikan()
        
        waktuTersisaInternal = durasi
        self.callbackWaktu = callback
        
        timerPublisher = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.waktuTersisaInternal -= 1
                self.callbackWaktu?(self.waktuTersisaInternal)
            }
    }
    
    func hentikan() {
        timerPublisher?.cancel()
        timerPublisher = nil
        callbackWaktu = nil
    }
}

// MARK: - Kalkulator Ukuran Kisi
class KalkulatorUkuranKisi {
    private let konfigurasi: KonfigurasiPermainan
    
    init(konfigurasi: KonfigurasiPermainan) {
        self.konfigurasi = konfigurasi
    }
    
    func hitung(tingkatSekarang: Int, skorSekarang: Int) -> Int {
        if let kesulitan = konfigurasi.tingkatKesulitan {
            return kesulitan.rawValue
        }
        
        if skorSekarang >= 50 {
            return 5
        } else if skorSekarang >= 20 {
            return 4
        } else {
            return 3
        }
    }
}

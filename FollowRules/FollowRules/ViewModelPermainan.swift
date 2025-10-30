//
//  ViewModelPermainan.swift
//  FollowRules
//
//  Game Screen ViewModel
//

import Foundation
import Combine
import UIKit

// MARK: - ViewModel Permainan (Game ViewModel)
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
    private var timerPublisher: AnyCancellable?
    
    // MARK: - Initialization
    init(layananPermainan: ProtocolLayananPermainan,
         koordinatorAnimasi: ProtocolKoordinatorAnimasi,
         konfigurasi: KonfigurasiPermainan) {
        self.layananPermainan = layananPermainan
        self.koordinatorAnimasi = koordinatorAnimasi
        self.konfigurasi = konfigurasi
        
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
        hentikanTimer()
        _ = layananPermainan.prosesAksiPemain(.keluarPermainan)
    }
    
    func dapatkanWarnaLatar() -> UIColor {
        return UIColor(red: 0.95, green: 0.95, blue: 0.90, alpha: 1.0)
    }
    
    func dapatkanWarnaHeader() -> UIColor {
        return UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
    }
    
    // MARK: - Private Methods
    
    private func konfigurasBindings() {
        layananPermainan.penerbitStatusPermainan
            .receive(on: DispatchQueue.main)
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
            self?.statusPermainan = snapshot.status
            self?.tingkatSekarang = snapshot.tingkatSekarang
            self?.skorSekarang = snapshot.skorSekarang
            self?.waktuTersisa = snapshot.waktuTersisa
            self?.kartuSekarang = snapshot.kartuSekarang
            self?.aturanSekarang = snapshot.aturanSekarang?.deskripsiTampilan ?? ""
            self?.kartuTerpilih = snapshot.kartuTerpilih
        }
    }
    
    private func perbaruiUkuranKisi() {
        if let kesulitan = konfigurasi.tingkatKesulitan {
            ukuranKisi = kesulitan.rawValue
        } else {
            // Mode waktu dengan kesulitan dinamis
            if skorSekarang >= 50 {
                ukuranKisi = 5
            } else if skorSekarang >= 20 {
                ukuranKisi = 4
            } else {
                ukuranKisi = 3
            }
        }
    }
    
    private func mulaiTimerWaktuJikaDiperlukan() {
        guard case .waktu = konfigurasi.mode else { return }
        
        hentikanTimer()
        
        timerPublisher = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if let waktu = self.waktuTersisa, waktu > 0 {
                    self.waktuTersisa = waktu - 1
                    
                    if waktu <= 10 {
                        self.jenisAnimasi = .peringatanWaktu
                    }
                }
            }
    }
    
    private func hentikanTimer() {
        timerPublisher?.cancel()
        timerPublisher = nil
    }
    
    deinit {
        hentikanTimer()
    }
}


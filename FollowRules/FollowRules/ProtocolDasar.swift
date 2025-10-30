//
//  ProtocolDasar.swift
//  FollowRules
//
//  Core Protocols & Architecture Foundation
//

import Foundation
import Combine

// MARK: - Protocol Repositori Penyimpanan (Storage Repository Protocol)
protocol ProtocolRepositoriPenyimpanan {
    func simpan<T: Codable>(_ nilai: T, untukKunci kunci: String) throws
    func muat<T: Codable>(untukKunci kunci: String) throws -> T?
    func hapus(untukKunci kunci: String) throws
    func hapusSemuaData() throws
}

// MARK: - Protocol Layanan Permainan (Game Service Protocol)
protocol ProtocolLayananPermainan {
    var penerbitStatusPermainan: AnyPublisher<StatusPermainan, Never> { get }
    var penerbitSkorSaatIni: AnyPublisher<Int, Never> { get }
    var penerbitTingkatSaatIni: AnyPublisher<Int, Never> { get }
    
    func inisialisasiPermainanBaru(denganKonfigurasi konfigurasi: KonfigurasiPermainan)
    func prosesAksiPemain(_ aksi: AksiPemain) -> HasilAksi
    func dapatkanStatusSaatIni() -> SnapshotStatusPermainan
    func setelUlangPermainan()
}

// MARK: - Protocol Pembuat Aturan (Rule Creator Protocol)
protocol ProtocolPembuatAturan {
    func buatAturanBaru(untukKonteks konteks: KonteksPermainan) -> EntitasAturan
    func validasiAturan(_ aturan: EntitasAturan, terhadapKartu kartu: [EntitasKartu]) -> Bool
}

// MARK: - Protocol Pembuat Kartu (Card Creator Protocol)
protocol ProtocolPembuatKartu {
    func buatKumpulanKartu(jumlah: Int, strategiPemilihan: StrategiPemilihanKartu) -> [EntitasKartu]
    func dapatkanSemuaKartuTersedia() -> [EntitasKartu]
}

// MARK: - Protocol Koordinator Animasi (Animation Coordinator Protocol)
protocol ProtocolKoordinatorAnimasi {
    func tampilkanAnimasi(_ jenisAnimasi: JenisAnimasi, padaKonteks konteks: KonteksAnimasi)
    func hentikanSemuaAnimasi()
}

// MARK: - Protocol Pengelola Skor (Score Manager Protocol)
protocol ProtocolPengelolaSkor {
    var penerbitSkorTertinggi: AnyPublisher<DaftarSkorTertinggi, Never> { get }
    
    func simpanSkor(_ skor: EntriSkor) throws
    func dapatkanSkorTertinggi(untukMode mode: JenisMode) -> [EntriSkor]
    func hapusSemuaSkor() throws
}

// MARK: - Model Data Entities

struct KonfigurasiPermainan {
    let mode: JenisMode
    let tingkatKesulitan: TingkatKesulitan?
    let durasiWaktu: TimeInterval?
    let konfigurasiKhusus: [String: Any]?
    
    init(mode: JenisMode, tingkatKesulitan: TingkatKesulitan? = nil, durasiWaktu: TimeInterval? = nil, konfigurasiKhusus: [String: Any]? = nil) {
        self.mode = mode
        self.tingkatKesulitan = tingkatKesulitan
        self.durasiWaktu = durasiWaktu
        self.konfigurasiKhusus = konfigurasiKhusus
    }
}

enum JenisMode: String, Codable {
    case tantangan
    case waktu
    case latihan
}

enum TingkatKesulitan: Int, Codable {
    case mudah = 3
    case sedang = 4
    case sulit = 5
    case pakar = 6
    
    var deskripsi: String {
        switch self {
        case .mudah: return "Easy"
        case .sedang: return "Medium"
        case .sulit: return "Hard"
        case .pakar: return "Expert"
        }
    }
}

enum StatusPermainan {
    case tidakDimulai
    case siapMulai
    case sedangBermain
    case jeda
    case menungguVerifikasi
    case selesaiSukses
    case selesaiGagal
    case selesaiWaktuHabis
}

struct SnapshotStatusPermainan {
    let status: StatusPermainan
    let tingkatSekarang: Int
    let skorSekarang: Int
    let waktuTersisa: TimeInterval?
    let kartuSekarang: [EntitasKartu]
    let aturanSekarang: EntitasAturan?
    let kartuTerpilih: Set<UUID>
    let metaData: [String: Any]
}

enum AksiPemain {
    case mulaiPermainan
    case pilihKartu(indeks: Int)
    case batalkanPilihan(indeks: Int)
    case verifikasiJawaban
    case lanjutkanTingkatBerikutnya
    case jedakanPermainan
    case lanjutkanPermainan
    case keluarPermainan
}

struct HasilAksi {
    let berhasil: Bool
    let pesan: String?
    let statusBaru: StatusPermainan
    let dataEfekSamping: [String: Any]?
}

struct KonteksPermainan {
    let tingkatSekarang: Int
    let jumlahKartu: Int
    let kartuTersedia: [EntitasKartu]
    let riwayatAturan: [EntitasAturan]
    let tingkatKompleksitas: Int
}

enum StrategiPemilihanKartu {
    case acak
    case berbobot([JenisKartu: Double])
    case diatur([EntitasKartu])
}

struct EntitasAturan {
    let id: UUID
    let jenisOperasi: JenisOperasiAturan
    let deskripsiTampilan: String
    let kriteriaPemilihan: (EntitasKartu) -> Bool
    let tingkatKompleksitas: Int
    let metadata: [String: Any]?
    
    init(id: UUID = UUID(), 
         jenisOperasi: JenisOperasiAturan,
         deskripsiTampilan: String,
         tingkatKompleksitas: Int = 1,
         metadata: [String: Any]? = nil,
         kriteriaPemilihan: @escaping (EntitasKartu) -> Bool) {
        self.id = id
        self.jenisOperasi = jenisOperasi
        self.deskripsiTampilan = deskripsiTampilan
        self.kriteriaPemilihan = kriteriaPemilihan
        self.tingkatKompleksitas = tingkatKompleksitas
        self.metadata = metadata
    }
}

enum JenisOperasiAturan {
    case hapusberdasarkanJenis([JenisKartu])
    case hapusBerdasarkanNilai([Int])
    case hapusBerdasarkanKondisi(String)
    case simpanBerdasarkanJenis([JenisKartu])
    case simpanBerdasarkanNilai([Int])
    case simpanBerdasarkanKondisi(String)
    case operasiKompleks(String)
}

struct EntitasKartu: Identifiable, Hashable, Codable {
    let id: UUID
    let jenis: JenisKartu
    let nilai: Int?
    let metadata: [String: String]?
    
    init(id: UUID = UUID(), jenis: JenisKartu, nilai: Int? = nil, metadata: [String: String]? = nil) {
        self.id = id
        self.jenis = jenis
        self.nilai = nilai
        self.metadata = metadata
    }
    
    var namaAset: String {
        if let nilai = nilai {
            return "\(jenis.rawValue)-\(nilai)"
        }
        return jenis.rawValue
    }
    
    var deskripsiLengkap: String {
        if let nilai = nilai {
            return "\(jenis.namaTampilan) \(nilai)"
        }
        return jenis.namaTampilan
    }
    
    static func == (lhs: EntitasKartu, rhs: EntitasKartu) -> Bool {
        return lhs.jenis == rhs.jenis && lhs.nilai == rhs.nilai
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(jenis)
        hasher.combine(nilai)
    }
}

enum JenisAnimasi {
    case munculKartu
    case hilangKartu
    case pilihanKartu
    case jawabanBenar
    case jawabanSalah
    case transisiTingkat
    case efekKonfeti
    case efekKilau
    case peringatanWaktu
}

struct KonteksAnimasi {
    let tampilan: Any
    let posisi: CGPoint?
    let kartu: [EntitasKartu]?
    let parameter: [String: Any]?
}

struct EntriSkor: Codable {
    let id: UUID
    let mode: JenisMode
    let skor: Int
    let tingkatDicapai: Int
    let tanggalCapai: Date
    let durasiPermainan: TimeInterval
    
    init(id: UUID = UUID(), mode: JenisMode, skor: Int, tingkatDicapai: Int, tanggalCapai: Date = Date(), durasiPermainan: TimeInterval = 0) {
        self.id = id
        self.mode = mode
        self.skor = skor
        self.tingkatDicapai = tingkatDicapai
        self.tanggalCapai = tanggalCapai
        self.durasiPermainan = durasiPermainan
    }
}

struct DaftarSkorTertinggi {
    var skorModeTantangan: [EntriSkor]
    var skorModeWaktu: [EntriSkor]
}


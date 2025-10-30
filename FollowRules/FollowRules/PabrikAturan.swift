//
//  PabrikAturan.swift
//  FollowRules
//
//  Rule Factory with Strategy Pattern
//

import Foundation

// MARK: - Pabrik Aturan (Rule Factory)
class PabrikAturan: ProtocolPembuatAturan {
    
    private let generatorAcak: GeneratorBilanganAcak
    private var riwayatAturanDibuat: [EntitasAturan] = []
    
    init(generatorAcak: GeneratorBilanganAcak = GeneratorAcakSistem()) {
        self.generatorAcak = generatorAcak
    }
    
    func buatAturanBaru(untukKonteks konteks: KonteksPermainan) -> EntitasAturan {
        let pembuatStrategiArray = dapatkanPembuatStrategiTersedia(konteks: konteks)
        
        // Pilih strategi secara acak
        let indeksAcak = generatorAcak.angkaAcak(dalam: 0..<pembuatStrategiArray.count)
        let pembuatStrategi = pembuatStrategiArray[indeksAcak]
        
        let aturan = pembuatStrategi.buat(dariKartu: konteks.kartuTersedia, kompleksitas: konteks.tingkatKompleksitas)
        
        // Simpan ke riwayat
        riwayatAturanDibuat.append(aturan)
        
        return aturan
    }
    
    func validasiAturan(_ aturan: EntitasAturan, terhadapKartu kartu: [EntitasKartu]) -> Bool {
        // Pastikan aturan memiliki setidaknya satu kartu yang cocok
        let kartuCocok = kartu.filter { aturan.kriteriaPemilihan($0) }
        
        // Aturan valid jika ada 1-n kartu yang cocok (bukan 0 atau semua)
        return !kartuCocok.isEmpty && kartuCocok.count < kartu.count
    }
    
    // MARK: - Private Methods
    
    private func dapatkanPembuatStrategiTersedia(konteks: KonteksPermainan) -> [StrategiPembuatAturan] {
        var strategi: [StrategiPembuatAturan] = []
        
        // Strategi dasar selalu tersedia
        strategi.append(StrategiHapusJenis())
        strategi.append(StrategiHapusNilai())
        strategi.append(StrategiSimpanJenis())
        strategi.append(StrategiSimpanNilai())
        
        // Strategi lanjutan untuk tingkat lebih tinggi
        if konteks.tingkatSekarang > 3 {
            strategi.append(StrategiHapusKategori())
            strategi.append(StrategiSimpanKategori())
        }
        
        // Strategi kompleks untuk tingkat tinggi
        if konteks.tingkatSekarang > 10 {
            strategi.append(StrategiKondisiKompleks())
        }
        
        return strategi
    }
}

// MARK: - Protocol Strategi Pembuat Aturan
protocol StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan
}

// MARK: - Strategi: Hapus Jenis
class StrategiHapusJenis: StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan {
        let jenisKartuAngka = Set(kartu.map { $0.jenis }.filter { $0.adalahKartuAngka })
        let jumlahJenis = min(kompleksitas, 2)
        let jenisTerpilih = Array(jenisKartuAngka.shuffled().prefix(jumlahJenis))
        
        guard !jenisTerpilih.isEmpty else {
            // Fallback jika tidak ada kartu angka
            let jenisApapun = Array(Set(kartu.map { $0.jenis }).shuffled().prefix(1))
            return buatAturanHapusJenis(jenisTerpilih: jenisApapun)
        }
        
        return buatAturanHapusJenis(jenisTerpilih: jenisTerpilih)
    }
    
    private func buatAturanHapusJenis(jenisTerpilih: [JenisKartu]) -> EntitasAturan {
        let deskripsi = "Remove all \(jenisTerpilih.map { $0.namaTampilan }.joined(separator: " and ")) tiles"
        
        return EntitasAturan(
            jenisOperasi: .hapusberdasarkanJenis(jenisTerpilih),
            deskripsiTampilan: deskripsi,
            tingkatKompleksitas: jenisTerpilih.count,
            kriteriaPemilihan: { kartu in
                jenisTerpilih.contains(kartu.jenis)
            }
        )
    }
}

// MARK: - Strategi: Hapus Nilai
class StrategiHapusNilai: StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan {
        let nilaiTersedia = Set(kartu.compactMap { $0.nilai })
        let jumlahNilai = min(kompleksitas + 1, 3)
        let nilaiTerpilih = Array(nilaiTersedia.shuffled().prefix(jumlahNilai))
        
        let deskripsi = "Remove all \(nilaiTerpilih.sorted().map { "\($0)" }.joined(separator: ", ")) tiles"
        
        return EntitasAturan(
            jenisOperasi: .hapusBerdasarkanNilai(nilaiTerpilih),
            deskripsiTampilan: deskripsi,
            tingkatKompleksitas: nilaiTerpilih.count,
            kriteriaPemilihan: { kartu in
                guard let nilai = kartu.nilai else { return false }
                return nilaiTerpilih.contains(nilai)
            }
        )
    }
}

// MARK: - Strategi: Simpan Jenis
class StrategiSimpanJenis: StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan {
        let jenisKartuAngka = Set(kartu.map { $0.jenis }.filter { $0.adalahKartuAngka })
        let jumlahJenis = min(kompleksitas, 2)
        let jenisTerpilih = Array(jenisKartuAngka.shuffled().prefix(jumlahJenis))
        
        guard !jenisTerpilih.isEmpty else {
            let jenisApapun = Array(Set(kartu.map { $0.jenis }).shuffled().prefix(1))
            return buatAturanSimpanJenis(jenisTerpilih: jenisApapun)
        }
        
        return buatAturanSimpanJenis(jenisTerpilih: jenisTerpilih)
    }
    
    private func buatAturanSimpanJenis(jenisTerpilih: [JenisKartu]) -> EntitasAturan {
        let deskripsi = "Keep only \(jenisTerpilih.map { $0.namaTampilan }.joined(separator: " and ")) tiles"
        
        return EntitasAturan(
            jenisOperasi: .simpanBerdasarkanJenis(jenisTerpilih),
            deskripsiTampilan: deskripsi,
            tingkatKompleksitas: jenisTerpilih.count,
            kriteriaPemilihan: { kartu in
                !jenisTerpilih.contains(kartu.jenis)
            }
        )
    }
}

// MARK: - Strategi: Simpan Nilai
class StrategiSimpanNilai: StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan {
        let nilaiTersedia = Set(kartu.compactMap { $0.nilai })
        let jumlahNilai = min(kompleksitas + 1, 3)
        let nilaiTerpilih = Array(nilaiTersedia.shuffled().prefix(jumlahNilai))
        
        let deskripsi = "Keep only \(nilaiTerpilih.sorted().map { "\($0)" }.joined(separator: ", ")) tiles"
        
        return EntitasAturan(
            jenisOperasi: .simpanBerdasarkanNilai(nilaiTerpilih),
            deskripsiTampilan: deskripsi,
            tingkatKompleksitas: nilaiTerpilih.count,
            kriteriaPemilihan: { kartu in
                guard let nilai = kartu.nilai else { return true }
                return !nilaiTerpilih.contains(nilai)
            }
        )
    }
}

// MARK: - Strategi: Hapus Kategori
class StrategiHapusKategori: StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan {
        let adaAngin = kartu.contains { $0.jenis.adalahKartuAngin }
        let adaKhusus = kartu.contains { $0.jenis.adalahKartuKhusus }
        
        if adaAngin && Bool.random() {
            return EntitasAturan(
                jenisOperasi: .hapusBerdasarkanKondisi("wind"),
                deskripsiTampilan: "Remove all Wind tiles",
                tingkatKompleksitas: 2,
                kriteriaPemilihan: { $0.jenis.adalahKartuAngin }
            )
        } else if adaKhusus {
            return EntitasAturan(
                jenisOperasi: .hapusBerdasarkanKondisi("dragon"),
                deskripsiTampilan: "Remove all Dragon tiles",
                tingkatKompleksitas: 2,
                kriteriaPemilihan: { $0.jenis.adalahKartuKhusus }
            )
        }
        
        // Fallback
        return StrategiHapusJenis().buat(dariKartu: kartu, kompleksitas: kompleksitas)
    }
}

// MARK: - Strategi: Simpan Kategori
class StrategiSimpanKategori: StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan {
        let adaAngin = kartu.contains { $0.jenis.adalahKartuAngin }
        let adaKhusus = kartu.contains { $0.jenis.adalahKartuKhusus }
        
        if adaAngin && Bool.random() {
            return EntitasAturan(
                jenisOperasi: .simpanBerdasarkanKondisi("wind"),
                deskripsiTampilan: "Keep only Wind tiles",
                tingkatKompleksitas: 2,
                kriteriaPemilihan: { !$0.jenis.adalahKartuAngin }
            )
        } else if adaKhusus {
            return EntitasAturan(
                jenisOperasi: .simpanBerdasarkanKondisi("dragon"),
                deskripsiTampilan: "Keep only Dragon tiles",
                tingkatKompleksitas: 2,
                kriteriaPemilihan: { !$0.jenis.adalahKartuKhusus }
            )
        }
        
        return StrategiSimpanJenis().buat(dariKartu: kartu, kompleksitas: kompleksitas)
    }
}

// MARK: - Strategi: Kondisi Kompleks
class StrategiKondisiKompleks: StrategiPembuatAturan {
    func buat(dariKartu kartu: [EntitasKartu], kompleksitas: Int) -> EntitasAturan {
        // Contoh: Hapus kartu dengan nilai ganjil atau genap
        let ganjil = Bool.random()
        let deskripsi = ganjil ? "Remove all odd numbered tiles" : "Remove all even numbered tiles"
        
        return EntitasAturan(
            jenisOperasi: .operasiKompleks(ganjil ? "odd" : "even"),
            deskripsiTampilan: deskripsi,
            tingkatKompleksitas: 3,
            kriteriaPemilihan: { kartu in
                guard let nilai = kartu.nilai else { return false }
                return ganjil ? (nilai % 2 == 1) : (nilai % 2 == 0)
            }
        )
    }
}



import Foundation

// MARK: - Pabrik Aturan (Rule Factory) - Refactored Implementation
class PabrikAturan: ProtocolPembuatAturan {
    
    private let generatorAcak: GeneratorBilanganAcak
    private var riwayatAturanDibuat: [EntitasAturan] = []
    private let rantaiPembuatAturan: RantaiPembuatAturan
    
    init(generatorAcak: GeneratorBilanganAcak = GeneratorAcakSistem()) {
        self.generatorAcak = generatorAcak
        self.rantaiPembuatAturan = RantaiPembuatAturan(generatorAcak: generatorAcak)
    }
    
    func buatAturanBaru(untukKonteks konteks: KonteksPermainan) -> EntitasAturan {
        let aturan = rantaiPembuatAturan.buatAturan(untukKonteks: konteks)
        riwayatAturanDibuat.append(aturan)
        return aturan
    }
    
    func validasiAturan(_ aturan: EntitasAturan, terhadapKartu kartu: [EntitasKartu]) -> Bool {
        let validator = ValidatorAturan()
        return validator.validasi(aturan: aturan, terhadapKartu: kartu)
    }
}

// MARK: - Rantai Pembuat Aturan (Chain of Responsibility)
class RantaiPembuatAturan {
    private let generatorAcak: GeneratorBilanganAcak
    private lazy var penanganPertama: PenanganPembuatAturan = {
        return konfigurasiRantai()
    }()
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
    }
    
    func buatAturan(untukKonteks konteks: KonteksPermainan) -> EntitasAturan {
        return penanganPertama.tanganiPermintaan(konteks: konteks)
    }
    
    private func konfigurasiRantai() -> PenanganPembuatAturan {
        let penanganDasar = PenanganAturanDasar(generatorAcak: generatorAcak)
        let penanganLanjutan = PenanganAturanLanjutan(generatorAcak: generatorAcak)
        let penanganKompleks = PenanganAturanKompleks(generatorAcak: generatorAcak)
        
        penanganDasar.setPenanganBerikutnya(penanganLanjutan)
        penanganLanjutan.setPenanganBerikutnya(penanganKompleks)
        
        return penanganDasar
    }
}

// MARK: - Protocol Penangan Pembuat Aturan
protocol PenanganPembuatAturan {
    func tanganiPermintaan(konteks: KonteksPermainan) -> EntitasAturan
    func setPenanganBerikutnya(_ penangan: PenanganPembuatAturan)
}

// MARK: - Penangan Aturan Dasar
class PenanganAturanDasar: PenanganPembuatAturan {
    private let generatorAcak: GeneratorBilanganAcak
    private var penanganBerikutnya: PenanganPembuatAturan?
    private let builderDasar: BuilderAturanDasar
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
        self.builderDasar = BuilderAturanDasar(generatorAcak: generatorAcak)
    }
    
    func tanganiPermintaan(konteks: KonteksPermainan) -> EntitasAturan {
        if konteks.tingkatSekarang <= 3 {
            return builderDasar.bangunAturan(untukKonteks: konteks)
        }
        
        return penanganBerikutnya?.tanganiPermintaan(konteks: konteks) ?? builderDasar.bangunAturan(untukKonteks: konteks)
    }
    
    func setPenanganBerikutnya(_ penangan: PenanganPembuatAturan) {
        penanganBerikutnya = penangan
    }
}

// MARK: - Penangan Aturan Lanjutan
class PenanganAturanLanjutan: PenanganPembuatAturan {
    private let generatorAcak: GeneratorBilanganAcak
    private var penanganBerikutnya: PenanganPembuatAturan?
    private let builderLanjutan: BuilderAturanLanjutan
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
        self.builderLanjutan = BuilderAturanLanjutan(generatorAcak: generatorAcak)
    }
    
    func tanganiPermintaan(konteks: KonteksPermainan) -> EntitasAturan {
        if konteks.tingkatSekarang > 3 && konteks.tingkatSekarang <= 10 {
            return builderLanjutan.bangunAturan(untukKonteks: konteks)
        }
        
        return penanganBerikutnya?.tanganiPermintaan(konteks: konteks) ?? builderLanjutan.bangunAturan(untukKonteks: konteks)
    }
    
    func setPenanganBerikutnya(_ penangan: PenanganPembuatAturan) {
        penanganBerikutnya = penangan
    }
}

// MARK: - Penangan Aturan Kompleks
class PenanganAturanKompleks: PenanganPembuatAturan {
    private let generatorAcak: GeneratorBilanganAcak
    private var penanganBerikutnya: PenanganPembuatAturan?
    private let builderKompleks: BuilderAturanKompleks
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
        self.builderKompleks = BuilderAturanKompleks(generatorAcak: generatorAcak)
    }
    
    func tanganiPermintaan(konteks: KonteksPermainan) -> EntitasAturan {
        if konteks.tingkatSekarang > 10 {
            return builderKompleks.bangunAturan(untukKonteks: konteks)
        }
        
        return penanganBerikutnya?.tanganiPermintaan(konteks: konteks) ?? builderKompleks.bangunAturan(untukKonteks: konteks)
    }
    
    func setPenanganBerikutnya(_ penangan: PenanganPembuatAturan) {
        penanganBerikutnya = penangan
    }
}

// MARK: - Builder Aturan Dasar
class BuilderAturanDasar {
    private let generatorAcak: GeneratorBilanganAcak
    private let daftarStrategi: [StrategiPembuatAturan]
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
        self.daftarStrategi = [
            StrategiHapusJenis(),
            StrategiHapusNilai(),
            StrategiSimpanJenis(),
            StrategiSimpanNilai()
        ]
    }
    
    func bangunAturan(untukKonteks konteks: KonteksPermainan) -> EntitasAturan {
        let indeksAcak = generatorAcak.angkaAcak(dalam: 0..<daftarStrategi.count)
        let strategi = daftarStrategi[indeksAcak]
        return strategi.buat(dariKartu: konteks.kartuTersedia, kompleksitas: konteks.tingkatKompleksitas)
    }
}

// MARK: - Builder Aturan Lanjutan
class BuilderAturanLanjutan {
    private let generatorAcak: GeneratorBilanganAcak
    private let daftarStrategi: [StrategiPembuatAturan]
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
        self.daftarStrategi = [
            StrategiHapusJenis(),
            StrategiHapusNilai(),
            StrategiSimpanJenis(),
            StrategiSimpanNilai(),
            StrategiHapusKategori(),
            StrategiSimpanKategori()
        ]
    }
    
    func bangunAturan(untukKonteks konteks: KonteksPermainan) -> EntitasAturan {
        let indeksAcak = generatorAcak.angkaAcak(dalam: 0..<daftarStrategi.count)
        let strategi = daftarStrategi[indeksAcak]
        return strategi.buat(dariKartu: konteks.kartuTersedia, kompleksitas: konteks.tingkatKompleksitas)
    }
}

// MARK: - Builder Aturan Kompleks
class BuilderAturanKompleks {
    private let generatorAcak: GeneratorBilanganAcak
    private let daftarStrategi: [StrategiPembuatAturan]
    
    init(generatorAcak: GeneratorBilanganAcak) {
        self.generatorAcak = generatorAcak
        self.daftarStrategi = [
            StrategiHapusJenis(),
            StrategiHapusNilai(),
            StrategiSimpanJenis(),
            StrategiSimpanNilai(),
            StrategiHapusKategori(),
            StrategiSimpanKategori(),
            StrategiKondisiKompleks()
        ]
    }
    
    func bangunAturan(untukKonteks konteks: KonteksPermainan) -> EntitasAturan {
        let indeksAcak = generatorAcak.angkaAcak(dalam: 0..<daftarStrategi.count)
        let strategi = daftarStrategi[indeksAcak]
        return strategi.buat(dariKartu: konteks.kartuTersedia, kompleksitas: konteks.tingkatKompleksitas)
    }
}

// MARK: - Validator Aturan
class ValidatorAturan {
    func validasi(aturan: EntitasAturan, terhadapKartu kartu: [EntitasKartu]) -> Bool {
        let kartuCocok = kartu.filter { aturan.kriteriaPemilihan($0) }
        return !kartuCocok.isEmpty && kartuCocok.count < kartu.count
    }
}

// MARK: - Protocol Strategi Pembuat Aturan (保持原有接口)
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

// CD ib - INT imm8 - Interrupt vector number specified by immediate byte
else if(Komut = $CD) then
begin

  if(Komut2 = $10) then
  begin

    {$IFDEF DEBUG} mmCikti.Lines.Add('int %.2d', [Komut2]); {$ENDIF}
    IPDegeriniArtir(2);

    // aktif olan bayrak, cs ve ip değerlerini yığına sakla
    YiginaEkle(Bayraklar, DU2);
    YiginaEkle(YZMC_DEGERSN[YZMC0_CS], DU2);
    YiginaEkle(YZMC_DEGERSN[YZMC0_EIP], DU2);

    { TODO - diğer bayrak değerleri de burada ayarlanacak }

    // çalıştırılacak kesme girişini belirle
    D21 := PWord(@Bellek144MB[(Komut2 * 4) + 0])^;
    D22 := PWord(@Bellek144MB[(Komut2 * 4) + 2])^;

    // kesme işlevini çalıştır
    YZMC_DEGERSN[YZMC0_EIP] := D21;
    YZMC_DEGERSN[YZMC0_CS] := D22;
  end
  else if(Komut2 = $13) then
  begin

    // 3.5" 1.44MB floppy disket değerleri
    // silindir sayısı: 0..79
    // kafa sayısı: 0..1
    // iz başına sektör sayısı: 1..18

    // aşağıdaki yazmaç değerleri hatalı geliyor
    D21 := YazmacDegerAl(YZMC_ES);      // es:bx

    D11 := YazmacDegerAl(YZMC_AH);      // ah = 2 = okuma
    D12 := YazmacDegerAl(YZMC_AL);      // işlem yapılacak sektör sayısı
    D13 := YazmacDegerAl(YZMC_DH);      // kafa sayısı
    D14 := YazmacDegerAl(YZMC_DL);      // sürücü numarası: $00=A: $80=C:
    D15 := YazmacDegerAl(YZMC_CH);      // silindir numarası
    D16 := YazmacDegerAl(YZMC_CL);      // sektör numarası
    D22 := YazmacDegerAl(YZMC_BX);
    BayrakDegistir(BAYRAK_CF, False);

    mmCikti.Lines.Add('int $13', []);
    mmCikti.Lines.Add('int ah: $%.2x', [D11]);
    mmCikti.Lines.Add('int al: $%.2x', [D12]);
    mmCikti.Lines.Add('int dh: $%.2x', [D13]);
    mmCikti.Lines.Add('int dl: $%.2x', [D14]);
    mmCikti.Lines.Add('int ch: $%.2x', [D15]);
    mmCikti.Lines.Add('int cl: $%.2x', [D16]);
    mmCikti.Lines.Add('int bx: $%.4x', [D22]);

    // ilk sektör
    //D41 := ((D13 * 18) + (D16 - 1)) * 512;
    D41 := (((D15 * 36) + (D13 * 18) + D16) - 1) * 512;

    // ah = hata kodu = 0 = başarılı
    // al okunan sektör sayısı
    // cf: 0 = işlem başarılı, 1 = hata

    DosyaYukle('disket144.img', (D21 * $10) + D22, D41, D12 * 512);

    YazmacDegistir(YZMC_AH, 0);
    BayrakDegistir(BAYRAK_CF, False);

    IPDegeriniArtir(2);

  end else Result := False;
end

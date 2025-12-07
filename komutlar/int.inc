// CD ib - INT imm8 - Interrupt vector number specified by immediate byte
else if(Komut = $CD) then
begin

  if(Komut2 = $13) then
  begin

    // aşağıdaki yazmaç değerleri hatalı geliyor
    D11 := YazmacDegerAl(YZMC_AH);
    D12 := YazmacDegerAl(YZMC_AL);
    D13 := YazmacDegerAl(YZMC_DH);
    D14 := YazmacDegerAl(YZMC_DL);
    D15 := YazmacDegerAl(YZMC_CH);
    D16 := YazmacDegerAl(YZMC_CL);
    D21 := YazmacDegerAl(YZMC_BX);
    BayrakDegistir(BAYRAK_CF, False);

    mmCikti.Lines.Add('int $13', []);
    mmCikti.Lines.Add('int ah: $%.2x', [D11]);
    mmCikti.Lines.Add('int al: $%.2x', [D12]);
    mmCikti.Lines.Add('int dh: $%.2x', [D13]);
    mmCikti.Lines.Add('int dl: $%.2x', [D14]);
    mmCikti.Lines.Add('int ch: $%.2x', [D15]);
    mmCikti.Lines.Add('int cl: $%.2x', [D16]);
    mmCikti.Lines.Add('int bx: $%.4x', [D21]);

    IPDegeriniArtir(2);
  end
  else
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
  end;
end

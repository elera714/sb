// CD ib - INT imm8 - Interrupt vector number specified by immediate byte
else if(IslenenKomut = $CD) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;
  {$IFDEF DEBUG} mmCikti.Lines.Add('int %.2d', [D11]); {$ENDIF}
  IPDegeriniArtir(2);

  // aktif olan bayrak, cs ve ip değerlerini yığına sakla
  YiginaEkle(Bayraklar, DU2);
  YiginaEkle(YZMC_DEGERSN[YZMC0_CS], DU2);
  YiginaEkle(YZMC_DEGERSN[YZMC0_EIP], DU2);

  { TODO - diğer bayrak değerleri de burada ayarlanacak }

  // çalıştırılacak kesme girişini belirle
  D21 := PWord(@Bellek144MB[(D11 * 4) + 0])^;
  D22 := PWord(@Bellek144MB[(D11 * 4) + 2])^;

  // kesme işlevini çalıştır
  YZMC_DEGERSN[YZMC0_EIP] := D21;
  YZMC_DEGERSN[YZMC0_CS] := D22;
end

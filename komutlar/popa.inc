else if(Komut = $61) then
begin

  // 61 - POPAD - Pop EDI, ESI, EBP, EBX, EDX, ECX, and EAX
  if(KomutModDegistir) then
  begin

    D41 := YigindanAl(DU4);
    YazmacDegistir(YZMC_EDI, D21);
    D41 := YigindanAl(DU4);
    YazmacDegistir(YZMC_ESI, D21);
    D41 := YigindanAl(DU4);
    YazmacDegistir(YZMC_EBP, D21);
    D41 := YigindanAl(DU4);
    //YazmacDegistir(YZMC_ESP, D21);
    D41 := YigindanAl(DU4);
    YazmacDegistir(YZMC_EBX, D21);
    D41 := YigindanAl(DU4);
    YazmacDegistir(YZMC_EDX, D21);
    D41 := YigindanAl(DU4);
    YazmacDegistir(YZMC_ECX, D21);
    D41 := YigindanAl(DU4);
    YazmacDegistir(YZMC_EAX, D21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('popad', []); {$ENDIF}
  end
  else
  // 61 - POPA - Pop DI, SI, BP, BX, DX, CX, and AX
  begin

    D21 := YigindanAl(DU2);
    YazmacDegistir(YZMC_DI, D21);
    D21 := YigindanAl(DU2);
    YazmacDegistir(YZMC_SI, D21);
    D21 := YigindanAl(DU2);
    YazmacDegistir(YZMC_BP, D21);
    D21 := YigindanAl(DU2);
    //YazmacDegistir(YZMC_SP, D21);
    D21 := YigindanAl(DU2);
    YazmacDegistir(YZMC_BX, D21);
    D21 := YigindanAl(DU2);
    YazmacDegistir(YZMC_DX, D21);
    D21 := YigindanAl(DU2);
    YazmacDegistir(YZMC_CX, D21);
    D21 := YigindanAl(DU2);
    YazmacDegistir(YZMC_AX, D21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('popa', []); {$ENDIF}
  end;

  IPDegeriniArtir;
end

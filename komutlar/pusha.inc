else if(Komut = $60) then
begin

  // 60 - PUSHAD - Push EAX, ECX, EDX, EBX, original ESP, EBP, ESI, and EDI
  if(KomutModDegistir) then
  begin

    D41 := YazmacDegerAl(YZMC_ESP);
    YiginaEkle2(YZMC_EAX);
    YiginaEkle2(YZMC_ECX);
    YiginaEkle2(YZMC_EDX);
    YiginaEkle2(YZMC_EBX);
    YiginaEkle(D41, DU4); // YZMC_ESP);
    YiginaEkle2(YZMC_EBP);
    YiginaEkle2(YZMC_ESI);
    YiginaEkle2(YZMC_EDI);
    {$IFDEF DEBUG} mmCikti.Lines.Add('pushad', []); {$ENDIF}
  end
  else
  // 60 - PUSHA - Push AX, CX, DX, BX, original SP, BP, SI, and DI
  begin

    D21 := YazmacDegerAl(YZMC_SP);
    YiginaEkle2(YZMC_AX);
    YiginaEkle2(YZMC_CX);
    YiginaEkle2(YZMC_DX);
    YiginaEkle2(YZMC_BX);
    YiginaEkle(D21, DU2); // YZMC_SP);
    YiginaEkle2(YZMC_BP);
    YiginaEkle2(YZMC_SI);
    YiginaEkle2(YZMC_DI);
    {$IFDEF DEBUG} mmCikti.Lines.Add('pusha', []); {$ENDIF}
  end;

  IPDegeriniArtir;
end

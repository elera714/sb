else if(Komut >= $58 + YZMC0_EAX) and (Komut <= $58 + YZMC0_EDI) then
begin

  // 58+ rd - POP r32 - Pop top of stack into r32; increment stack pointer
  if(KomutModDegistir) then
  begin

    D41 := YigindanAl(DU4);
    YazmacDegistir(($04 shl 8) or (Komut - $58), D41);
    {$IFDEF DEBUG} mmCikti.Lines.Add('pop %s', [Yazmaclar32[Komut - $58]]); {$ENDIF}
  end
  else
  // 58+ rw - POP r16 - Pop top of stack into r16; increment stack pointer
  begin

    D21 := YigindanAl(DU2);
    YazmacDegistir(($02 shl 8) or (Komut - $58), D21);
    {$IFDEF DEBUG} mmCikti.Lines.Add('pop %s', [Yazmaclar16[Komut - $58]]); {$ENDIF}
  end;

  IPDegeriniArtir;
end
// 1F - POP DS - Pop top of stack into DS; increment stack pointer
else if(Komut = $1F) then
begin

  D21 := YigindanAl(DU2);
  YazmacDegistir(YZMC_DS, D21);
  {$IFDEF DEBUG} mmCikti.Lines.Add('pop ds'); {$ENDIF}
  IPDegeriniArtir;
end
// 07 - POP ES - Pop top of stack into ES; increment stack pointer
else if(Komut = $07) then
begin

  D21 := YigindanAl(DU2);
  YazmacDegistir(YZMC_ES, D21);
  {$IFDEF DEBUG} mmCikti.Lines.Add('pop es'); {$ENDIF}
  IPDegeriniArtir;
end
// 17 - POP SS - Pop top of stack into SS; increment stack pointer
else if(Komut = $17) then
begin

  D21 := YigindanAl(DU2);
  YazmacDegistir(YZMC_SS, D21);
  {$IFDEF DEBUG} mmCikti.Lines.Add('pop ss'); {$ENDIF}
  IPDegeriniArtir;
end
// 0F A1 - POP FS - Pop top of stack into FS; increment stack pointer
else if(Komut = $0F) and (Komut2 = $A1) then
begin

  D21 := YigindanAl(DU2);
  YazmacDegistir(YZMC_FS, D21);
  {$IFDEF DEBUG} mmCikti.Lines.Add('pop fs'); {$ENDIF}
  IPDegeriniArtir(2);
end
// 0F A9 - POP GS - Pop top of stack into GS; increment stack pointer
else if(Komut = $0F) and (Komut2 = $A9) then
begin

  D21 := YigindanAl(DU2);
  YazmacDegistir(YZMC_GS, D21);
  {$IFDEF DEBUG} mmCikti.Lines.Add('pop gs'); {$ENDIF}
  IPDegeriniArtir(2);
end

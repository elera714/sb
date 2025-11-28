else if(IslenenKomut >= $50 + YZMC0_EAX) and (IslenenKomut <= $50 + YZMC0_EDI) then
begin

  // 50+rd - PUSH r32 - Push r32
  if(KomutModDegistir) then
  begin

    YiginaEkle2(($04 shl 8) or (IslenenKomut - $50));
    {$IFDEF DEBUG} mmCikti.Lines.Add('push %s', [Yazmaclar32[IslenenKomut - $50]]); {$ENDIF}
  end
  else
  // 50+rw - PUSH r16 - Push r16
  begin

    YiginaEkle2(($02 shl 8) or (IslenenKomut - $50));
    {$IFDEF DEBUG} mmCikti.Lines.Add('push %s', [Yazmaclar16[IslenenKomut - $50]]); {$ENDIF}
  end;

  IPDegeriniArtir;
end
// 6A - PUSH imm8 - Push imm8
else if(IslenenKomut = $6A) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;

  YiginaEkle(D11, DU1);
  {$IFDEF DEBUG} mmCikti.Lines.Add('push vu1 $%.2x', [D11]); {$ENDIF}
  IPDegeriniArtir(1 + 1);
end
else if(IslenenKomut = $68) then
begin

  // 68 - PUSH imm32 - Push imm32
  if(KomutModDegistir) then
  begin

    D41 := PLongWord(@Bellek144MB[Adres + 1])^;

    YiginaEkle(D41, DU4);
    {$IFDEF DEBUG} mmCikti.Lines.Add('push vu4 $%.8x', [D41]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
  end
  else
  // 68 - PUSH imm16 - Push imm16
  begin

    D21 := PWord(@Bellek144MB[Adres + 1])^;

    YiginaEkle(D21, DU2);
    {$IFDEF DEBUG} mmCikti.Lines.Add('push vu2 $%.4x', [D21]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
  end;
end
// 0E - PUSH CS - Push CS
else if(IslenenKomut = $0E) then
begin

  YiginaEkle2(YZMC_CS);
  {$IFDEF DEBUG} mmCikti.Lines.Add('push cs'); {$ENDIF}
  IPDegeriniArtir;
end
// 16 - PUSH SS - Push SS
else if(IslenenKomut = $16) then
begin

  YiginaEkle2(YZMC_SS);
  {$IFDEF DEBUG} mmCikti.Lines.Add('push ss'); {$ENDIF}
  IPDegeriniArtir;
end
// 1E - PUSH DS - Push DS
else if(IslenenKomut = $1E) then
begin

  YiginaEkle2(YZMC_DS);
  {$IFDEF DEBUG} mmCikti.Lines.Add('push ds'); {$ENDIF}
  IPDegeriniArtir;
end
// 06 - PUSH ES - Push ES
else if(IslenenKomut = $06) then
begin

  YiginaEkle2(YZMC_ES);
  {$IFDEF DEBUG} mmCikti.Lines.Add('push es'); {$ENDIF}
  IPDegeriniArtir;
end
// 0F A0 - PUSH FS - Push FS
else if(IslenenKomut = $0F) and (BirSonrakiKomut = $A0) then
begin

  YiginaEkle2(YZMC_FS);
  {$IFDEF DEBUG} mmCikti.Lines.Add('push fs'); {$ENDIF}
  IPDegeriniArtir(2);
end
// 0F A8 - PUSH GS - Push GS
else if(IslenenKomut = $0F) and (BirSonrakiKomut = $A8) then
begin

  YiginaEkle2(YZMC_GS);
  {$IFDEF DEBUG} mmCikti.Lines.Add('push gs'); {$ENDIF}
  IPDegeriniArtir(2);
end

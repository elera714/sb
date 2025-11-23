// 40+ rw - INC r16 - Increment word register by 1
// 40+ rd - INC r32 - Increment doubleword register by 1
else if(IslenenKomut >= $40 + YZMC0_EAX) and (IslenenKomut <= $40 + YZMC0_EDI) then
begin

  if(KomutModDegistir) then
  begin

    YazmacDegistir2(($04 shl 8) or (IslenenKomut - $40), 1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('inc %s', [Yazmaclar32[IslenenKomut - $40]]); {$ENDIF}
  end
  else
  begin

    YazmacDegistir2(($03 shl 8) or (IslenenKomut - $40), 1, True);
    {$IFDEF DEBUG} mmCikti.Lines.Add('inc %s', [Yazmaclar16[IslenenKomut - $40]]); {$ENDIF}
  end;

  IPDegeriniArtir;
end

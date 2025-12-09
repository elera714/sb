else if(Komut = $9D) then
begin

  // 9D - POPFD - Pop top of stack into EFLAGS
  if(KomutModDegistir) then
  begin

    D41 := YigindanAl(DU4);
    Bayraklar := D41;
    BayraklariGuncelle;
    {$IFDEF DEBUG} mmCikti.Lines.Add('popfd'); {$ENDIF}
  end
  else
  // 9D - POPF - Pop top of stack into lower 16 bits of EFLAGS
  begin

    D41 := YigindanAl(DU2);
    Bayraklar := D41;
    BayraklariGuncelle;
    {$IFDEF DEBUG} mmCikti.Lines.Add('popf'); {$ENDIF}
  end;

  IPDegeriniArtir;
end

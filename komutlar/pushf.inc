else if(Komut = $9C) then
begin

  // 9C - PUSHFD - Push EFLAGS
  if(KomutModDegistir) then
  begin

    YiginaEkle(Bayraklar, DU4);
    BayraklariGuncelle;
    {$IFDEF DEBUG} mmCikti.Lines.Add('pushfd'); {$ENDIF}
  end
  else
  // 9C - PUSHF - Push lower 16 bits of EFLAGS
  begin

    YiginaEkle(Bayraklar, DU2);
    BayraklariGuncelle;
    {$IFDEF DEBUG} mmCikti.Lines.Add('pushf'); {$ENDIF}
  end;

  IPDegeriniArtir;
end

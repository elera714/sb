// EB cb - JMP rel8
else if(Komut = $EB) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) $%.2x', [ShortInt(Komut2)]); {$ENDIF}
  IPDegeriniArtir(1 + 1);
  IPDegeriniArtir(ShortInt(Komut2));
end
else if(Komut = $E9) then
begin

  // E9 cd - JMP rel32 - Jump near, relative, displacement relative to next instruction
  if(KomutModDegistir) then
  begin

    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) $%.4x', [SmallInt(D21)]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
    IPDegeriniArtir(SmallInt(D21));
  end
  else
  // E9 cw - JMP rel16 - Jump near, relative, displacement relative to next instruction
  begin

    D41 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) $%.8x', [LongInt(D41)]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
    IPDegeriniArtir(LongInt(D41));
  end;
end

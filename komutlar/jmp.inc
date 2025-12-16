else if(Komut = $E9) then
begin

  // E9 cd - JMP rel32 - Jump near, relative, displacement relative to next instruction
  if(KomutModDegistir) then
  begin

    D21 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) %d', [SmallInt(D21)]); {$ENDIF}
    IPDegeriniArtir(1 + 2);
    IPDegeriniArtir(SmallInt(D21));
  end
  else
  // E9 cw - JMP rel16 - Jump near, relative, displacement relative to next instruction
  begin

    D41 := PWord(@Bellek144MB[IslenenAdres + 1])^;
    {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) %d', [LongInt(D41)]); {$ENDIF}
    IPDegeriniArtir(1 + 4);
    IPDegeriniArtir(LongInt(D41));
  end;
end
// EA cd - JMP ptr16:16 - Jump far, absolute, address given in operand
// EA cp - JMP ptr16:32 - Jump far, absolute, address given in operand
else if(Komut = $EA) then
begin

  D22 := PWord(@Bellek144MB[IslenenAdres + 1])^;    // ip
  D21 := PWord(@Bellek144MB[IslenenAdres + 3])^;    // cs

  {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (uzak) $%.4x:$%.4x', [D21, D22]); {$ENDIF}

  YZMC_DEGERSN[YZMC0_CS] := D21;
  YZMC_DEGERSN[YZMC0_EIP] := D22;

  Result := isIslendi;
end
// EB cb - JMP rel8
else if(Komut = $EB) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) %d', [ShortInt(Komut2)]); {$ENDIF}
  IPDegeriniArtir(1 + 1);
  IPDegeriniArtir(ShortInt(Komut2));
end

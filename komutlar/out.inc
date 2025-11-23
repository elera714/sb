// E6 ib - OUT imm8, AL - Output byte in AL to I/O port address imm8
// E7 ib - OUT imm8, AX - Output word in AX to I/O port address imm8
// E7 ib - OUT imm8, EAX - Output doubleword in EAX to I/O port address imm8
else if(IslenenKomut = $E6) or (IslenenKomut = $E7) then
begin

  V11 := (Bellek144MB[Adres + 1] and $FF);

  if(IslenenKomut = $E6) then
  begin

    IOPortYaz(V11, YZMC_AL);
    {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,al', [V11 and $FF]); {$ENDIF}
    IPDegeriniArtir(2);
  end
  else if(IslenenKomut = $E7) then
  begin

    if(KomutModDegistir) then
    begin

      IOPortYaz(V11, YZMC_EAX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,eax', [V11 and $FF]); {$ENDIF}
    end
    else
    begin

      IOPortYaz(V11, YZMC_AX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,ax', [V11 and $FF]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
// EE - OUT DX, AL - Output byte in AL to I/O port address in DX
// EF - OUT DX, AX - Output word in AX to I/O port address in DX
// EF - OUT DX, EAX - Output doubleword in EAX to I/O port address in DX  else if(IslenenKomut = $EC) or (IslenenKomut = $ED) then
else if(IslenenKomut = $EE) or (IslenenKomut = $EF) then
begin

  if(IslenenKomut = $EE) then
  begin

    IOPortYaz2(YZMC_AL);
    {$IFDEF DEBUG} mmCikti.Lines.Add('out dx,al'); {$ENDIF}
    IPDegeriniArtir;
  end
  else if(IslenenKomut = $EF) then
  begin

    if(KomutModDegistir) then
    begin

      IOPortYaz2(YZMC_EAX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out dx,eax'); {$ENDIF}
    end
    else
    begin

      IOPortYaz2(YZMC_AX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out dx,ax'); {$ENDIF}
    end;

    IPDegeriniArtir;

  end else Result := False;
end

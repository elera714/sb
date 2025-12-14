// E6 ib - OUT imm8, AL - Output byte in AL to I/O port address imm8
// E7 ib - OUT imm8, AX - Output word in AX to I/O port address imm8
// E7 ib - OUT imm8, EAX - Output doubleword in EAX to I/O port address imm8
else if(Komut = $E6) or (Komut = $E7) then
begin

  if(Komut = $E6) then
  begin

    IOPortYaz(Komut2, YZMC_AL);
    {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,al', [Komut2 and $FF]); {$ENDIF}
    IPDegeriniArtir(2);
  end
  else if(Komut = $E7) then
  begin

    if(KomutModDegistir) then
    begin

      IOPortYaz(Komut2, YZMC_EAX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,eax', [Komut2 and $FF]); {$ENDIF}
    end
    else
    begin

      IOPortYaz(Komut2, YZMC_AX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('out $%.2x,ax', [Komut2 and $FF]); {$ENDIF}
    end;

    IPDegeriniArtir(2);
  end;
end
// EE - OUT DX, AL - Output byte in AL to I/O port address in DX
// EF - OUT DX, AX - Output word in AX to I/O port address in DX
// EF - OUT DX, EAX - Output doubleword in EAX to I/O port address in DX  else if(Komut = $EC) or (Komut = $ED) then
else if(Komut = $EE) or (Komut = $EF) then
begin

  if(Komut = $EE) then
  begin

    IOPortYaz2(YZMC_AL);
    {$IFDEF DEBUG} mmCikti.Lines.Add('out dx,al'); {$ENDIF}
    IPDegeriniArtir;
  end
  else if(Komut = $EF) then
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
  end;
end

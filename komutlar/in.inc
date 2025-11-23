// E4 - ib IN AL,imm8 - Input byte from imm8 I/O port address into AL
// E5 - ib IN AX,imm8 - Input byte from imm8 I/O port address into AX
// E5 - ib IN EAX,imm8 - Input byte from imm8 I/O port address into EAX
else if(IslenenKomut = $E4) or (IslenenKomut = $E5) then
begin

  V11 := Bellek144MB[Adres + 1];

  if(IslenenKomut = $E4) then
  begin

    IOPortOku(YZMC_AL, V11);
    {$IFDEF DEBUG} mmCikti.Lines.Add('in al,$%.2x', [V11 and $FF]); {$ENDIF}
    IPDegeriniArtir(2);
  end
  else if(IslenenKomut = $E5) then
  begin

    if(KomutModDegistir) then
    begin

      IOPortOku(YZMC_EAX, V11);
      {$IFDEF DEBUG} mmCikti.Lines.Add('in eax,$%.2x', [V11 and $FF]); {$ENDIF}
    end
    else
    begin

      IOPortOku(YZMC_AX, V11);
      {$IFDEF DEBUG} mmCikti.Lines.Add('in ax,$%.2x', [V11 and $FF]); {$ENDIF}
    end;

    IPDegeriniArtir(2);

  end else Result := False;
end
// EC - IN AL,DX - Input byte from I/O port in DX into AL
// ED - IN AX,DX - Input word from I/O port in DX into AX
// ED - IN EAX,DX - Input doubleword from I/O port in DX into EAX
else if(IslenenKomut = $EC) or (IslenenKomut = $ED) then
begin

  if(IslenenKomut = $EC) then
  begin

    IOPortOku2(YZMC_AL);
    {$IFDEF DEBUG} mmCikti.Lines.Add('in al,dx'); {$ENDIF}
    IPDegeriniArtir;
  end
  else if(IslenenKomut = $ED) then
  begin

    if(KomutModDegistir) then
    begin

      IOPortOku2(YZMC_EAX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('in eax,dx'); {$ENDIF}
    end
    else
    begin

      IOPortOku2(YZMC_AX);
      {$IFDEF DEBUG} mmCikti.Lines.Add('in ax,dx'); {$ENDIF}
    end;

    IPDegeriniArtir;

  end else Result := False;
end

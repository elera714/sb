// 72 cb JB rel8 Jump short if below (CF=1)
// 72 cb JC rel8 Jump short if carry (CF=1)
// 72 cb JNAE rel8 Jump short if not above or equal (CF=1)
else if(Komut = $72) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('jb/jc/jnae (yakın) %.2d', [ShortInt(Komut2)]); {$ENDIF}
  IPDegeriniArtir(2);

  if(GetBit(Bayraklar, BAYRAK_CF)) then IPDegeriniArtir(ShortInt(Komut2));
end
// 73 cb - JAE rel8 - Jump short if above or equal (CF=0)
// 73 cb - JNB rel8 - Jump short if not below (CF=0)
// 73 cb - JNC rel8 - Jump short if not carry (CF=0)
else if(Komut = $73) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('jae/jnb/jnc (yakın) %.2d', [ShortInt(Komut2)]); {$ENDIF}
  IPDegeriniArtir(2);

  if not(GetBit(Bayraklar, BAYRAK_CF)) then IPDegeriniArtir(ShortInt(Komut2));
end
// 74 cb - JE rel8 - Jump short if equal (ZF=1)
// 74 cb - JZ rel8 - Jump short if zero (ZF = 1)
else if(Komut = $74) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('je/jz (yakın) %.2d', [ShortInt(Komut2)]); {$ENDIF}
  IPDegeriniArtir(2);

  if(GetBit(Bayraklar, BAYRAK_ZF)) then IPDegeriniArtir(ShortInt(Komut2));
end
// 75 cb - JNE rel8 - Jump short if not equal (ZF=0)
// 75 cb - JNZ rel8 - Jump short if not zero (ZF=0)
else if(Komut = $75) then
begin

  {$IFDEF DEBUG} mmCikti.Lines.Add('jne/jnz (yakın) %.2d', [ShortInt(Komut2)]); {$ENDIF}
  IPDegeriniArtir(2);

  if not(GetBit(Bayraklar, BAYRAK_ZF)) then IPDegeriniArtir(ShortInt(Komut2));
end
// 0F 82 cw/cd - JB rel16/32 - Jump near if below (CF=1)
// 0F 82 cw/cd - JC rel16/32 - Jump near if carry (CF=1)
// 0F 82 cw/cd - JNAE rel16/32 - Jump near if not above or equal (CF=1)
else if(Komut = $0F) and (Komut2 = $82) then
begin

  D21 := PWord(@Bellek144MB[IslenenAdres + 2])^;
  {$IFDEF DEBUG} mmCikti.Lines.Add('jb/jc/jnae (yakın) %.4d', [SmallInt(D21)]); {$ENDIF}
  IPDegeriniArtir(2 + 2);

  if(GetBit(Bayraklar, BAYRAK_CF)) then IPDegeriniArtir(SmallInt(D21));
end

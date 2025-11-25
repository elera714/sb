// 74 cb - JZ rel8 - Jump short if zero (ZF = 1)
else if(IslenenKomut = $74) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;
  {$IFDEF DEBUG} mmCikti.Lines.Add('jz (yakın) %.2d', [ShortInt(D11)]); {$ENDIF}
  IPDegeriniArtir(2);

  if(GetBit(Bayraklar, BAYRAK_ZF)) then IPDegeriniArtir(ShortInt(D11));
end

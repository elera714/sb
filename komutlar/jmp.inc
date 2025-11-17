// EB cb - JMP rel8
else if(IslenenKomut = $EB) then
begin

  V11 := PByte(@Bellek144MB[Adres + 1])^;
  {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) %.2d', [ShortInt(V11)]); {$ENDIF}
  IPDegeriniArtir(2);
  IPDegeriniArtir(ShortInt(V11));
end

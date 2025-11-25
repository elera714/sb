// EB cb - JMP rel8
else if(IslenenKomut = $EB) then
begin

  D11 := PByte(@Bellek144MB[Adres + 1])^;
  {$IFDEF DEBUG} mmCikti.Lines.Add('jmp (yakın) %.2d', [ShortInt(D11)]); {$ENDIF}
  IPDegeriniArtir(2);
  IPDegeriniArtir(ShortInt(D11));
end

// E8 cw - CALL rel16 - Call near, relative, displacement relative to next instruction
// E8 cd - CALL rel32 - Call near, relative, displacement relative to next instruction
else if(IslenenKomut = $E8) then
begin

  D21 := PWord(@Bellek144MB[Adres + 1])^;
  {$IFDEF DEBUG} mmCikti.Lines.Add('call (yakın) %.4d', [SmallInt(D21)]); {$ENDIF}
  YiginaEkle(YZMC_DEGERSN[YZMC0_EIP] + 3, DU2);
  IPDegeriniArtir(3);
  IPDegeriniArtir(SmallInt(D21));
end

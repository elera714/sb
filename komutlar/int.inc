// CD ib - INT imm8 - Interrupt vector number specified by immediate byte
else if(Komut = $CD) then
begin

  if(Komut2 = $10) then
  begin

    D11 := YazmacDegerAl(YZMC_AH);
    if(D11 = $0E) then
    begin

      GostergeGuncelle := True;

      D12 := YazmacDegerAl(YZMC_AL);
      // satırbaşı işareti
      if(D12 = $0D) then
      begin

        GostergeX := 0;
        GostergeGuncelle := False;
      end
      // yeni satır işareti
      else if(D12 = $0A) then
      begin

        GostergeX := 79;
      end
      else
      begin

        D21 := ((GostergeY * 80) + GostergeX) * 2;

        D11 := YazmacDegerAl(YZMC_AL);
        PByte(@Bellek144MB[YAZIEKRAN_BELLEKADRESI + D21 + 0])^ := D11;
        PByte(@Bellek144MB[YAZIEKRAN_BELLEKADRESI + D21 + 1])^ := 15;
      end;

      if(GostergeGuncelle) then
      begin

        Inc(GostergeX);
        if(GostergeX = 80) then
        begin

          GostergeX := 0;
          Inc(GostergeY);
          if(GostergeY = 25) then
          begin

            GostergeX := 0;
            GostergeY := 0;
          end;
        end;
      end;

      {$IFDEF DEBUG} mmCikti.Lines.Add('int $%.2x', [Komut2]); {$ENDIF}
      IPDegeriniArtir(2);
    end
    else if(D11 = $4F) then
    begin

      YazmacDegistir(YZMC_AX, $004F);
      //BayrakDegistir(BAYRAK_CF, False);
      IPDegeriniArtir(2);
    end;
  end
  else if(Komut2 = $13) then
  begin

    D11 := YazmacDegerAl(YZMC_AH);

    // sürücüleri  sıfırla
    if(D11 = $00) then
    begin

      YazmacDegistir(YZMC_AH, 0);
      BayrakDegistir(BAYRAK_CF, False);

      mmCikti.Lines.Add('kesme: $%.2x:$%.2x', [Komut2, D11]);
      IPDegeriniArtir(2);
    end
    else if(D11 = $02) then
    begin

      // 3.5" 1.44MB floppy disket değerleri
      // silindir sayısı: 0..79
      // kafa sayısı: 0..1
      // iz başına sektör sayısı: 1..18

      // aşağıdaki yazmaç değerleri hatalı geliyor
      D41 := YazmacDegerAl(YZMC_ES);      // es:bx

      D11 := YazmacDegerAl(YZMC_AH);      // ah = 2 = okuma
      D12 := YazmacDegerAl(YZMC_AL);      // işlem yapılacak sektör sayısı
      D13 := YazmacDegerAl(YZMC_DH);      // kafa sayısı
      D14 := YazmacDegerAl(YZMC_DL);      // sürücü numarası: $00=A: $80=C:
      D15 := YazmacDegerAl(YZMC_CH);      // silindir numarası
      D16 := YazmacDegerAl(YZMC_CL);      // sektör numarası
      D22 := YazmacDegerAl(YZMC_BX);
      BayrakDegistir(BAYRAK_CF, False);

      // ilk sektör
      //D42 := ((D13 * 18) + (D16 - 1)) * 512;
      D42 := (((D15 * 36) + (D13 * 18) + D16) - 1) * 512;

      // ah = hata kodu = 0 = başarılı
      // al okunan sektör sayısı
      // cf: 0 = işlem başarılı, 1 = hata

      {if(D22 = $400) then
      begin

        DosyaYukle('disket144.img', (D41 * $10) + D22, D42, D12 * 512);
      end
      else
      begin

        DosyaYukle('disket144.img', (D41 * $10) + D22, D42 + 1024, D12 * 512);

        mmCikti.Lines.Add('int $13', []);
        mmCikti.Lines.Add('int ah: $%.2x', [D11]);
        mmCikti.Lines.Add('int al: $%.2x', [D12]);
        mmCikti.Lines.Add('int dh: $%.2x', [D13]);
        mmCikti.Lines.Add('int dl: $%.2x', [D14]);
        mmCikti.Lines.Add('int ch: $%.2x', [D15]);
        mmCikti.Lines.Add('int cl: $%.2x', [D16]);
        mmCikti.Lines.Add('int bx: $%.4x', [D22]);
        mmCikti.Lines.Add('D: %x', [D42]);
      end;}

      DosyaYukle(DisketImajDosyaAdi, (D41 * $10) + D22, D42, D12 * 512);

      YazmacDegistir(YZMC_AH, 0);
      BayrakDegistir(BAYRAK_CF, False);

      {$IFDEF DEBUG} mmCikti.Lines.Add('int $%.2x', [Komut2]); {$ENDIF}
      IPDegeriniArtir(2);
    end
    else
    begin

      mmCikti.Lines.Add('int hatası: $%.2x:$%.2x', [Komut2, D11]);
    end;
  end
  // klavye kesmesi
  else if(Komut2 = $16) then
  begin

    D11 := YazmacDegerAl(YZMC_AH);
    // basılan tuşu al
    if(D11 = $00) then
    begin

      { TODO - geliştirilecek }
      while BasilanTusSayisi = 0 do
      begin

        Application.ProcessMessages;
      end;

      YazmacDegistir(YZMC_AH, BasilanTus);
      YazmacDegistir(YZMC_AL, BasilanTus);

      IPDegeriniArtir(2);
    end;
  end
  // bilgisayarı yeniden başlat kesmesi
  else if(Komut2 = $19) then
  begin

    Result := isYenidenBaslat;
  end;
end

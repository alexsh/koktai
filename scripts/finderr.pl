
print "原稿格式常犯錯誤檢查程式    2000 年 2 月 12 日版\n\n";

$start = -1;
while (($start < 0) || ($start > 446)) {
        print "請輸入起始檔案編號 (0 ~ 446)：";
        $start = <STDIN>;
        chop ($start);
}

$stop = -1;
while (($stop < $start) || ($stop > 446)) {
        print "請輸入結束檔案編號 ($start ~ 446)：";
        $stop = <STDIN>;
        chop ($stop);
}

open (OUTPUT, ">finderr.out") || die "Cannot open output file finderr.out\n";
print "\n檢查到的錯誤將會寫在 finderr.out 這個檔案中。\n檢查中，請稍候...\n";
$oldfh = select (OUTPUT);

for ($i = $start; $i <= $stop; $i++) {
        $fn = $i;
        $fn = "0" . $fn if $i < 100;
        $fn = "0" . $fn if $i < 10;
        $fn = "c:\\dic\\" . $fn . ".dic";

        open (FILE, $fn) || die "Cannot open file $fn\n";

        while (<FILE>) {
                chop;
                if ($_ eq "~fm3;　") {
                        $_ = <FILE>;
                        chop;
                        if ($_ ne "") {
                                print "在 $fn 檔案的第 $. 行，為強迫空行(~fm3;　)的後一行，應為空行，請檢查！\n";
                        }
                }
                if (/^~bb2;【/) {
                        if ($last ne "") {
                                print "在 $fn 檔案的第 ".($.-1)." 行，為詞條前一行，應為空行，請檢查！\n";
                        }
                }
                if (/t108/) {
                        if ($last ne "") {
                                print "在 $fn 檔案的第 ".($.-1)." 行，為目頭字前一行，應為空行，請檢查！\n";
                        }
                }
                $len = length;
                if ($len > 500) {
                       print "在 $fn 檔案的第 $. 行達到 $len 個字元，可能產生問題，請檢查！\n";
                }
                $last = $_;
                if (index ($_, "(  )") > 0) {
                        print "在 $fn 檔案的第 $. 行出現有小括號夾著兩個半形空白 (而非一個全形空白)，請檢查！\n";
                }
                if (/( |　){5,}/) {
                        print "在 $fn 檔案的第 $. 行有許\多空白，請檢查！\n";
                }
                s/ //g;
                if (/^(　)+$/) {
                        print "在 $fn 檔案的第 $. 行出現有獨立的全形空白，請檢查！\n";
                }
                if (index ($_, "~bb2;【", 1) > 0) {
                        print "在 $fn 檔案的第 $. 行出現有加粗的詞條參考 bb2;【...】bb1;，請檢查！\n";
                }
                if (/~fk;..~fk;/) {
                        print "在 $fn 檔案的第 $. 行出現有 ~fk;..~fk;，請檢查！\n";
                }

                $found = index ($_, "��");
                while ($found != -1) {
                        $offset = 0;
                        while ($offset < $found) {
                                $c = ord (substr ($_, $offset));
                                if ((0x81 <= $c) && ($c <= 0xFE)) {
                                        $offset += 2;
                                } else {
                                        $offset++;
                                }
                        }
                        if ($offset == $found) {
                                print "在 $fn 檔案的第 $. 行出現有雙斜線 �窗A請檢查！\n";
                        }
                        $found = index ($_, "��", $found+1);
                }

                if ((/^（(國音|台甘|普閩)\)/) ||        # 全 + 半
                    (/^ ?\((國音|台甘|普閩)\)/)) {      # 半 + 半
                        print "在 $fn 檔案的第 $. 行出現有半形與全形括號配對，請檢查！\n";
                }

                if ((substr($_, 0, 2) eq " (") &&       # 半形
                    (substr($_, 6, 2) eq "）")) {       # 全形
                        print "在 $fn 檔案的第 $. 行出現有半形與全形括號配對，請檢查！ (strange)\n";
                }

                if ((substr($_, 0, 1) eq "(") &&        # 半形
                    (substr($_, 5, 2) eq "）")) {       # 全形
                        print "在 $fn 檔案的第 $. 行出現有半形與全形括號配對，請檢查！\n";
                }

                $tilde = 0;
                $len = length ($_);
                $offset = 0;
                while ($offset < $len) {
                        $c = ord (substr ($_, $offset));
                        if ((0x81 <= $c) && ($c <= 0xFE)) {
                                $c = ord (substr ($_, $offset+1));
                                if (((0x40 <= $c) && ($c <= 0x7E)) ||
                                    ((0xA1 <= $c) && ($c <= 0xFE))) {
                                        $offset += 2;
                                        next;
                                } else {
                                        print "在 $fn 檔案的第 $. 行第 ".($offset+1)." 字元有非 BIG-5 碼範圍字元，請檢查！\n";
                                }
                        }
                        if ($c == ord('~')) { $tilde++; }
                        if ($c == ord(';')) { $tilde--; }
                        $offset++;
                }
                if ($tilde != 0) {
                        print "在 $fn 檔案的第 $. 行有列印控制符號不成對情形，請檢查！\n";
                }
                if ($offset > $len) {
                        print "在 $fn 檔案的第 $. 行有意外的錯誤情況發生，請檢查！\n";
                }

                $fk = 0;
                $fm3 = 0;
                $offset = ($[-1);
                while (($offset = index($_, "~fk;", $offset+1)) != ($[-1)) {
                        $fk++;
                }
                $offset = ($[-1);
                while (($offset = index($_, "~fm3;", $offset+1)) != ($[-1)) {
                        $fm3++;
                }
                if (($fk != $fm3) && ($_ ne "~fm3;") && ($_ ne "~fm3;　")) {
                        print "在 $fn 檔案的第 $. 行有 ~fk; ~fm3; 不成對情形，請檢查！\n";
                }
                if (/(\?|？){3,}/) {
                        print "在 $fn 檔案的第 $. 行有三個以上連續問號，請檢查！\n";
                }
        }

        if ($last ne "") {
                print "在 $fn 檔案的最後一行出現有文字，請檢查！\n";
        }

        close (FILE);
}

select ($oldfh);
close (OUTPUT);

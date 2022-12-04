qui gen industry = ""
qui replace industry = "A" if NACE2>=1 & NACE2<=3
qui replace industry = "B" if NACE2>=4 & NACE2<=9
qui replace industry = "C10-C12" if NACE2>=10 & NACE2<=12
qui replace industry = "C13-C15" if NACE2>=13 & NACE2<=15
qui replace industry = "C16" if NACE2==16
qui replace industry = "C17" if NACE2==17
qui replace industry = "C18" if NACE2==18
qui replace industry = "C19" if NACE2==19
qui replace industry = "C20" if NACE2==20
qui replace industry = "C21" if NACE2==21
qui replace industry = "C22" if NACE2==22
qui replace industry = "C23" if NACE2==23
qui replace industry = "C24" if NACE2==24
qui replace industry = "C25" if NACE2==25
qui replace industry = "C26" if NACE2==26
qui replace industry = "C27" if NACE2==27
qui replace industry = "C28" if NACE2==28
qui replace industry = "C29" if NACE2==29
qui replace industry = "C30" if NACE2==30
qui replace industry = "C31-C32" if NACE2>=31 & NACE2<=32
qui replace industry = "C33" if NACE2==33
qui replace industry = "D" if NACE2==35
qui replace industry = "E36" if NACE2==36
qui replace industry = "E37-E39" if NACE2>=37 & NACE2<=39
qui replace industry = "F" if NACE2>=41 & NACE2<=43
qui replace industry = "G45" if NACE2==45
qui replace industry = "G46" if NACE2==46
qui replace industry = "G47" if NACE2==47
qui replace industry = "H49" if NACE2==49
qui replace industry = "H50" if  NACE2==50
qui replace industry = "H51" if NACE2==51
qui replace industry = "H52" if NACE2==52
qui replace industry = "H53" if NACE2==53
qui replace industry = "I" if NACE2>=55 & NACE2<=56
qui replace industry = "J58" if NACE2==58
qui replace industry = "J59-J60" if NACE2>=59 & NACE2<=60
qui replace industry = "J61" if NACE2==61
qui replace industry = "J62-J63" if NACE2>=62 & NACE2<=63
qui replace industry = "K64" if NACE2==64
qui replace industry = "K65" if NACE2==65
qui replace industry = "K66" if NACE2==66
qui replace industry = "L" if NACE2==68
qui replace industry = "M69-M70" if NACE2>=69 & NACE2<=70
qui replace industry = "M71" if NACE2==71
qui replace industry = "M72" if NACE2==72
qui replace industry = "M73" if NACE2==73
qui replace industry = "M74-M75" if NACE2>=74 & NACE2<=75
qui replace industry = "N77" if NACE2==77
qui replace industry = "N78" if NACE2==78
qui replace industry = "N79" if NACE2==79
qui replace industry = "N80-N82" if NACE2>=80 & NACE2<=82
qui replace industry = "O" if NACE2==84
qui replace industry = "P" if NACE2==85
qui replace industry = "Q86" if NACE2==86
qui replace industry = "Q87-Q88" if NACE2>=87 & NACE2<=88
qui replace industry = "R90-R92" if NACE2>=90 & NACE2<=92
qui replace industry = "R93" if NACE2==93
qui replace industry = "S94" if NACE2==94
qui replace industry = "S95" if NACE2==95
qui replace industry = "S96" if NACE2==96

program define statoffice

qui import delim using "${path1}data-table-`1'.csv", delim(";") varnames(1) clear
qui rename value `1'
qui g time = monthly(ïtime,"YM")
qui g month = month(dofm(time))
qui g year = year(dofm(time))
drop time
sort year month
qui compress
end
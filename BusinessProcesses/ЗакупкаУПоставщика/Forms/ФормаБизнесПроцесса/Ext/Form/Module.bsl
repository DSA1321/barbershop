﻿&НаСервере
Процедура ОбновитьКартуМаршрута()
	ОбъектПроцесс = РеквизитФормыВЗначение("Объект");
	КартаМаршрута = ОбъектПроцесс.ПолучитьКартуМаршрута();
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	ОбновитьКартуМаршрута();
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	ОбновитьКартуМаршрута();
КонецПроцедуры

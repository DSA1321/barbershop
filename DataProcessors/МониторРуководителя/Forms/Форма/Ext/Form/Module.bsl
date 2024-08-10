﻿&НаСервере
Процедура ЗаполнитьДанныеНаСервере()
	ЗаполнитьЧисловыеПоказатели();
	ЗаполнитьГистограммы();
    ЗаполнитьКруговыеДиаграммы();
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
    ЗаполнитьДанныеНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьЧисловыеПоказатели()
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаНачала", ПериодОбработки);
	Запрос.УстановитьПараметр("ДатаОкончания", КонецМесяца(ПериодОбработки));
	Запрос.Текст=
	"ВЫБРАТЬ
	|    ПродажиОбороты.Регистратор КАК Регистратор,
	|    ПродажиОбороты.СуммаОборот КАК СуммаОборот,
	|    ПродажиОбороты.КоличествоОборот КАК КоличествоОборот
	|ПОМЕСТИТЬ ВТ_Продажи
	|ИЗ
	|    РегистрНакопления.Продажи.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, ) КАК ПродажиОбороты
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    СУММА(ВТ_Продажи.СуммаОборот) КАК СуммаОборот
	|ИЗ
	|    ВТ_Продажи КАК ВТ_Продажи
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    СУММА(ВТ_Продажи.СуммаОборот) КАК СуммаОборот,
	|    КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_Продажи.Регистратор) КАК Регистратор
	|ПОМЕСТИТЬ ВТ_КоличествоРегистраторов
	|ИЗ
	|    ВТ_Продажи КАК ВТ_Продажи
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    ВЫБОР
	|        КОГДА ВТ_КоличествоРегистраторов.Регистратор = 0
	|            ТОГДА 0
	|        ИНАЧЕ ВЫРАЗИТЬ(ВТ_КоличествоРегистраторов.СуммаОборот / ВТ_КоличествоРегистраторов.Регистратор КАК ЧИСЛО(10, 2))
	|    КОНЕЦ КАК СреднийЧек
	|ИЗ
	|    ВТ_КоличествоРегистраторов КАК ВТ_КоличествоРегистраторов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    ЗаказыКлиентов.Регистратор КАК Регистратор
	|ПОМЕСТИТЬ ВТ_ЗаписиКлиентов
	|ИЗ
	|    РегистрНакопления.ЗаказыКлиентов КАК ЗаказыКлиентов
	|ГДЕ
	|    ЗаказыКлиентов.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|    И ЗаказыКлиентов.Регистратор ССЫЛКА Документ.ЗаписьКлиента
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_ЗаписиКлиентов.Регистратор) КАК КоличествоЗаписейКлиентов
	|ИЗ
	|    ВТ_ЗаписиКлиентов КАК ВТ_ЗаписиКлиентов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_ЗаписиКлиентов.Регистратор) КАК Завершенных
	|ИЗ
	|    ВТ_ЗаписиКлиентов КАК ВТ_ЗаписиКлиентов
	|        ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровИУслуг КАК РеализацияТоваровИУслуг
	|        ПО ВТ_ЗаписиКлиентов.Регистратор = РеализацияТоваровИУслуг.ДокументОснование
	|ГДЕ
	|    РеализацияТоваровИУслуг.Проведен";
	ВсегоЗаписей = 0;
	РезультатПакет = Запрос.ВыполнитьПакет();
	ВыборкаПродажи = РезультатПакет[1].Выбрать();
	Если ВыборкаПродажи.Следующий() Тогда
		ВыручкаЧисло = ВыборкаПродажи.СуммаОборот;
	КонецЕсли;
	ВыборкаСреднийЧек = РезультатПакет[3].Выбрать();
	Если ВыборкаСреднийЧек.Следующий() Тогда
		СреднийЧек = ВыборкаСреднийЧек.СреднийЧек;
	КонецЕсли;
	ВыборкаЗаписиКлиентов = РезультатПакет[5].Выбрать();
	Если ВыборкаЗаписиКлиентов.Следующий() Тогда
		ВсегоЗаписей = ВыборкаЗаписиКлиентов.КоличествоЗаписейКлиентов;
	КонецЕсли;
	ВыборкаЗаписиКлиентовЗавершенные = РезультатПакет[6].Выбрать();
	Если ВыборкаЗаписиКлиентовЗавершенные.Следующий() Тогда
		Завершенных = ВыборкаЗаписиКлиентовЗавершенные.Завершенных;
		Если ВсегоЗаписей > 0 Тогда
			ПроцентЗавершенных = ОКР((100*Завершенных/ВсегоЗаписей),2);
			ЗавершенныхПроцентСтрока = СтрШаблон("Это %1 процентов от всех записей", ПроцентЗавершенных); 
		Иначе
			ЗавершенныхПроцентСтрока = "В этом периоде нет записей клиентов!";
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьГистограммы()
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|    НачалоПериода(Продажи.Период, День) КАК Период,
	|    Продажи.СуммаОборот КАК СуммаОборот
	|ИЗ
	|    РегистрНакопления.Продажи.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, ) КАК Продажи
	|
	|УПОРЯДОЧИТЬ ПО
	|    Период
	|ИТОГИ
	|    СУММА(СуммаОборот)
	|ПО
	|    Период ПЕРИОДАМИ(ДЕНЬ, &ДатаНачала, &ДатаОкончания)";
	Запрос.УстановитьПараметр("ДатаНачала", ПериодОбработки);
	Запрос.УстановитьПараметр("ДатаОкончания", КонецМесяца(ПериодОбработки));
	ДиаграммаВыручка.Обновление = Ложь;
	ДиаграммаВыручка.Очистить();
	Серия = ДиаграммаВыручка.Серии.Добавить("Оборот");
	Серия.Цвет = WebЦвета.ЛососьСветлый;
	Выборка = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Период", "Все");
	НомерЗаписи = 0;
	ТекущийОстаток = 0;
	ОстатокВчера = 0;
	Пока Выборка.Следующий() Цикл
		Точка = ДиаграммаВыручка.Точки.Добавить(Выборка.Период);
		Точка.Текст = Формат(Выборка.Период, "ДФ=dd.MM.yy");
		Точка.Расшифровка = Выборка.Период;
		Подсказка = "Выручка " + Выборка.СуммаОборот + " на " + Формат(Выборка.Период, "ДФ=dd.MM.yyyy"); 
		ДиаграммаВыручка.УстановитьЗначение(Точка, Серия, Выборка.СуммаОборот, Точка.Расшифровка, Подсказка);
	КонецЦикла;
	ДиаграммаВыручка.Обновление = Истина;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьКруговыеДиаграммы()
	ЗаполнитьДиаграммуПоИсточникамИнформации();
	ЗаполнитьДиаграммуПоСотрудникам();
	ЗаполнитьДиаграммуПоУслугам();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДиаграммуПоУслугам()
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|    Продажи.Номенклатура КАК Номенклатура,
	|    СУММА(Продажи.СуммаОборот) КАК СуммаОборот
	|ПОМЕСТИТЬ ВТ_КонкретныеУслуги
	|ИЗ
	|    РегистрНакопления.Продажи.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипНоменклатуры.Услуга)) КАК Продажи
	|ГДЕ
	|    Продажи.КоличествоОборот <> 0
	|
	|СГРУППИРОВАТЬ ПО
	|    Продажи.Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    СУММА(ПродажиОбороты.СуммаОборот) КАК СуммаОборот
	|ПОМЕСТИТЬ ВТ_ВсеПродажи
	|ИЗ
	|    РегистрНакопления.Продажи.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипНоменклатуры.Услуга)) КАК ПродажиОбороты
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    ВТ_КонкретныеУслуги.Номенклатура КАК Номенклатура,
	|    ВТ_КонкретныеУслуги.СуммаОборот КАК СуммаПродажНоменклатуры,
	|    ВТ_ВсеПродажи.СуммаОборот КАК ОбщаяСуммаПоУслугам
	|ПОМЕСТИТЬ ВТ_Предытог
	|ИЗ
	|    ВТ_КонкретныеУслуги КАК ВТ_КонкретныеУслуги
	|        ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ВсеПродажи КАК ВТ_ВсеПродажи
	|        ПО (ИСТИНА)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    ВЫБОР
	|        КОГДА 100 * ВТ_Предытог.СуммаПродажНоменклатуры / ВТ_Предытог.ОбщаяСуммаПоУслугам > 10
	|            ТОГДА ВТ_Предытог.Номенклатура.Представление
	|        ИНАЧЕ ""Прочее""
	|    КОНЕЦ КАК Номенклатура,
	|    СУММА(ВТ_Предытог.СуммаПродажНоменклатуры) КАК Сумма
	|ИЗ
	|    ВТ_Предытог КАК ВТ_Предытог
	|
	|СГРУППИРОВАТЬ ПО
	|    ВЫБОР
	|        КОГДА 100 * ВТ_Предытог.СуммаПродажНоменклатуры / ВТ_Предытог.ОбщаяСуммаПоУслугам > 10
	|            ТОГДА ВТ_Предытог.Номенклатура.Представление
	|        ИНАЧЕ ""Прочее""
	|    КОНЕЦ";
	Запрос.УстановитьПараметр("ДатаНачала", ПериодОбработки);
	Запрос.УстановитьПараметр("ДатаОкончания", КонецМесяца(ПериодОбработки));
	ДиаграммаВыручкаПоУслугам.Обновление = Ложь; //1
	ДиаграммаВыручкаПоУслугам.Очистить();
	Точка = ДиаграммаВыручкаПоУслугам.Точки.Добавить("Сумма"); //2
	Точка.Текст = "Сумма";
	Точка.ПриоритетЦвета = Ложь;
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Серия = ДиаграммаВыручкаПоУслугам.Серии.Добавить(Выборка.Номенклатура); //3
		ДиаграммаВыручкаПоУслугам.УстановитьЗначение(Точка, Серия, Выборка.Сумма, Строка(Выборка.Сумма));
	КонецЦикла;
	ДиаграммаВыручкаПоУслугам.Обновление = Истина;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДиаграммуПоИсточникамИнформации()
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЕСТЬNULL(Продажи.Клиент.ИсточникОткудаУзналОБарбешопе.Представление, ""Не указан"") КАК ИсточникИнформации,
	|	СУММА(Продажи.КоличествоОборот) КАК Количество
	|ИЗ
	|	РегистрНакопления.Продажи.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, ) КАК Продажи
	|ГДЕ
	|	Продажи.КоличествоОборот <> 0
	|
	|СГРУППИРОВАТЬ ПО
	|	ЕСТЬNULL(Продажи.Клиент.ИсточникОткудаУзналОБарбешопе.Представление, ""Не указан"")";	
	Запрос.УстановитьПараметр("ДатаНачала", ПериодОбработки);
	Запрос.УстановитьПараметр("ДатаОкончания", КонецМесяца(ПериодОбработки));
	ДиаграммаПоРекламнымИсточникам.Обновление = Ложь;
	ДиаграммаПоРекламнымИсточникам.Очистить();
	Точка = ДиаграммаПоРекламнымИсточникам.Точки.Добавить("Количество");
	Точка.Текст = "Количество";
	Точка.ПриоритетЦвета = Ложь;
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Серия = ДиаграммаПоРекламнымИсточникам.Серии.Добавить(Выборка.ИсточникИнформации);
		ДиаграммаПоРекламнымИсточникам.УстановитьЗначение(Точка, Серия, Выборка.Количество, Строка(Выборка.Количество));
	КонецЦикла;
	ДиаграммаПоРекламнымИсточникам.Обновление = Истина;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДиаграммуПоСотрудникам()
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|    СУММА(Продажи.СуммаОборот) КАК Сумма,
	|    Продажи.Сотрудник.Представление КАК Сотрудник
	|ИЗ
	|    РегистрНакопления.Продажи.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, ) КАК Продажи
	|ГДЕ
	|    Продажи.КоличествоОборот <> 0
	|
	|СГРУППИРОВАТЬ ПО
	|    Продажи.Сотрудник.Представление";
	Запрос.УстановитьПараметр("ДатаНачала", ПериодОбработки);
	Запрос.УстановитьПараметр("ДатаОкончания", КонецМесяца(ПериодОбработки));
	ДиаграммаВыручкаПоСотрудникам.Обновление = Ложь;
	ДиаграммаВыручкаПоСотрудникам.Очистить();
	Точка = ДиаграммаВыручкаПоСотрудникам.Точки.Добавить("Сумма");
	Точка.Текст = "Сумма";
	Точка.ПриоритетЦвета = Ложь;
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Серия = ДиаграммаВыручкаПоСотрудникам.Серии.Добавить(Выборка.Сотрудник);
		ДиаграммаВыручкаПоСотрудникам.УстановитьЗначение(Точка, Серия, Выборка.Сумма, Строка(Выборка.Сумма));
	КонецЦикла;
	ДиаграммаВыручкаПоСотрудникам.Обновление = Истина;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ПериодОбработки = НачалоМесяца(ТекущаяДата());
	МесяцСтрокой = Формат(ПериодОбработки, "ДФ='ММММ гггг'");
    ЗаполнитьДанныеНаСервере();
КонецПроцедуры 

&НаКлиенте
Процедура МесяцСтрокойНажатие(Элемент, СтандартнаяОбработка)
    СтандартнаяОбработка = Ложь;
    Подсказка = "Введите период получения данных";
    ЧастьДаты = ЧастиДаты.Дата;
    Оповещение = Новый ОписаниеОповещения("ПослеВводаПериода",ЭтотОбъект);
    ПоказатьВводДаты(Оповещение, ПериодОбработки, Подсказка, ЧастьДаты);
КонецПроцедуры

&НаКлиенте
Процедура ПослеВводаПериода(Результат, ДополнительныеПараметры) Экспорт
    Если Результат <> Неопределено Тогда
        ПериодОбработки = НачалоМесяца(Результат);
        МесяцСтрокой = Формат(ПериодОбработки, "ДФ='ММММ гггг'");
    КонецЕсли;    
    ЗаполнитьДанныеНаСервере();
КонецПроцедуры

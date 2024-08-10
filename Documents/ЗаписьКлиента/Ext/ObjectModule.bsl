﻿Процедура ОбработкаПроведения(Отказ, Режим)
	Движения.ЗаказыКлиентов.Записывать = Истина;
	Для Каждого ТекСтрокаУслуги Из Услуги Цикл
		Движение = Движения.ЗаказыКлиентов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Номенклатура = ТекСтрокаУслуги.Номенклатура;
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.ДатаЗаписи = ДатаЗаписи;
		Движение.Количество = ТекСтрокаУслуги.Количество;
		Движение.Сумма = ТекСтрокаУслуги.Сумма;
	КонецЦикла;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если НЕ ЗначениеЗаполнено(АвторДокумента) Тогда
		АторДокумента = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	СуммаДокумента = Услуги.Итог("Сумма");
	Если ЗначениеЗаполнено(Ссылка) И УслугаОказана = Ложь Тогда
		ПроверитьОказаниеУслуг();
	КонецЕсли;
	ДлительностьУслуг = РассчитатьДатуОкончанияЗаписи();
	Если ДлительностьУслуг = 0 Тогда
		ДлительностьУслуг = 60;
	КонецЕсли;
	ДатаОкончанияЗаписи = ДатаЗаписи + ДлительностьУслуг*60;
КонецПроцедуры

Процедура ПроверитьОказаниеУслуг()
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДокументОснование",Ссылка);	
	Запрос.Текст = "ВЫБРАТЬ
	|    РеализацияТоваровИУслуг.Ссылка КАК Ссылка
	|ИЗ
	|    Документ.РеализацияТоваровИУслуг КАК РеализацияТоваровИУслуг
	|ГДЕ
	|    РеализацияТоваровИУслуг.ДокументОснование = &ДокументОснование
	|    И РеализацияТоваровИУслуг.Проведен
	|
	|СГРУППИРОВАТЬ ПО
	|    РеализацияТоваровИУслуг.Ссылка";	
	Рез = Запрос.Выполнить();
	Если НЕ Рез.Пустой() Тогда
		УслугаОказана = Истина;
	КонецЕсли;	
КонецПроцедуры

Функция РассчитатьДатуОкончанияЗаписи()
	ТЧУслуги = Услуги.Выгрузить(, "Номенклатура");
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТЧУслуги", ТЧУслуги);
	Запрос.Текст=
	"ВЫБРАТЬ
	|    ТЧУслуги.Номенклатура КАК Номенклатура
	|ПОМЕСТИТЬ ВТ_Номенклатура
	|ИЗ
	|    &ТЧУслуги КАК ТЧУслуги
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|    СУММА(Ном.ДлительностьУслуги) КАК ДлительностьУслуги
	|ИЗ
	|    ВТ_Номенклатура КАК ВТ_Номенклатура
	|        ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Ном
	|        ПО ВТ_Номенклатура.Номенклатура = Ном.Ссылка";
	Рез = Запрос.Выполнить();
	Если Рез.Пустой() Тогда
		возврат 0;
	КонецЕсли;
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	возврат Выборка.ДлительностьУслуги;
КонецФункции

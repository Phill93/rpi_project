function configureMoment(){
	var momentDe = moment.locale('de', {
		months : "Januar_Februar_März_April_Mai_Juni_Juli_August_September_Oktober_November_Dezember".split("_"),
		//monthsShort : "janv._févr._mars_avr._mai_juin_juil._août_sept._oct._nov._déc.".split("_"),
		weekdays : "Montag_Dienstag_Mittwoch_Donnerstag_Freitag_Samstag_Sonntag".split("_"),
		weekdaysShort : "Mo_Di_Mi_Do_Fr_Sa_So".split("_"),
		longDateFormat : {
			LT : "HH:mm",
			LTS : "HH:mm:ss",
			L : "DD.MM.YYYY",
			LL : "D MMMM YYYY",
			LLL : "D. MMMM YYYY LTS",
			LLLL : "dddd D MMMM YYYY LT"
		},
		calendar : {
			sameDay: "[Heute] LT",
			nextDay: '[Morgen] LT',
			nextWeek: 'dddd [um] LT',
			lastDay: '[Gestern um] LT',
			lastWeek: 'dddd [um] LT',
			sameElse: 'L'
		},
		relativeTime : {
			future : "in %s",
			past : "nach %s",
			s : "Sekunden",
			m : "eine Minute",
			mm : "%d Minuten",
			h : "eine Stunde",
			hh : "%d Stunden",
			d : "ein Tag",
			dd : "%d Tage",
			M : "ein Monat",
			MM : "%d Monate",
			y : "ein Jahr",
			yy : "%d Jahre"
		},
		ordinalParse : /\d{1,2}(erste|zweite)/,
		ordinal : function (number) {
			return number + (number === 1 ? 'er' : 'ème');
		},
		//meridiemParse: /PD|MD/,
		week : {
			dow : 1, // Monday is the first day of the week.
			doy : 4  // The week that contains Jan 4th is the first week of the year.
		}
	});
	return momentDe;
}
local Translations = {
    error = {
        no_deposit = "€%{value} Borg vereist",
        cancelled = "Geannuleerd",
        vehicle_not_correct = "Dit is geen bedrijfsvoertuig!",
        no_driver = "Je moet rijden om dit te doen..",
        no_work_done = "Je hebt geen enkele taak voltooid..",
        backdoors_not_open = "De achterdeur is niet open",
        get_out_vehicle = "Je moet uit het voertuig stappen om deze actie te voltooien",
        too_far_from_trunk = "Je moet de dozen uit de achterkant van je voertuig pakken",
        too_far_from_delivery = "Je moet dichter bij de afleverlocatie zijn"
    },
    success = {
        paid_with_cash = "€%{value} borg contant betaald",
        paid_with_bank = "€%{value} borg via bankoverschrijving betaald",
        refund_to_cash = "€%{value} borg contant terugbetaald",
        you_earned = "Je hebt verdiend: €%{value}",
        payslip_time = "Alle taken voltooid.. Je kunt je salaris ophalen!",
    },
    menu = {
        header = "Beschikbare Voertuigen",
        close_menu = "⬅ Menu Sluiten",
    },
    mission = {
        store_reached = "Je bent bij de winkel, pak een doos uit de achterkant met [E] en lever die af op de marker",
        take_box = "Pak een doos met producten",
        deliver_box = "Lever een doos met producten af",
        another_box = "Haal nog een doos met producten",
        goto_next_point = "Alle dozen afgeleverd, ga naar de volgende levering",
        return_to_station = "Alle producten afgeleverd, ga terug naar het bedrijf",
        job_completed = "Je hebt je route voltooid, je kunt je salaris ophalen"
    },
    info = {
        deliver_e = "[E] - Producten afleveren",
        deliver = "Producten afleveren",
    }
}
if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

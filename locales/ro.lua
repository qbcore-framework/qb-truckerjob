local Translations = {
    error = {
        no_deposit = "$%{value} Trebuie sa platesti vehiculul",
        cancelled = "Anulat",
        vehicle_not_correct = "Acesta nu este un vehicul comercial!",
        no_driver = "Trebuie sa fii soferul vehiculului ca sa faci acest lucru..",
        no_work_done = "Nu ai facut nimic pana acum..",
        backdoors_not_open = "Usile din spate nu sunt deschise",
        get_out_vehicle = "Trebuie sa cobori din masina ca sa faci acesta actiune",
        too_far_from_trunk = "Trebuie sa iei cutii din portbagajul vehiculului tau.",
        too_far_from_delivery = "Trebuie sa fii mai aproape de locul de livrare"
    },
    success = {
        paid_with_cash = "$%{value} Depozit platit cu Cash",
        paid_with_bank = "$%{value} Depozit platit din Banca",
        refund_to_cash = "$%{value} Depozit platiti cu Cash",
        you_earned = "Ai castigat $%{value}",
        payslip_time = "Ai fost la toate magazinele. .. Timpul sa iti iei salarul!",
    },
    menu = {
        header = "Vehicule",
        close_menu = "⬅ Inchide Meniu",
    },
    mission = {
        store_reached = "Ai ajuns la magazin. Ia cutii din portbagaj si dule [E] la marker",
        take_box = "Ia o cutie cu produse",
        deliver_box = "Livreaza cutia cu produse",
        another_box = "Ia o alta cutie cu produse",
        goto_next_point = "Ai ;asat marfa la magazin. catre urmatorul magazin",
        return_to_station = "Ai livrat toata marfa. Inapoi la sediu",
        job_completed = "Ti-ai terminat ruta. Dute si iati salarul"
    },
    info = {
        deliver_e = "~g~E~w~ - Livreaza Produse",
        deliver = "Livreaza Produse",
    }
}

if GetConvar('qb_locale', 'en') == 'ro' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

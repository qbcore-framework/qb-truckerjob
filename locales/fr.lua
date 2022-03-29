local Translations = {
    error = {
        no_deposit = "$%{value} dépôt requis",
        cancelled = "Annulé",
        vehicle_not_correct = "Ce n'est pas un véhicule commercial!",
        no_driver = "Vous devez être le conducteur du véhicule!",
        no_work_done = "Vous n'avez pas encore travaillé.",
    },
    success = {
        paid_with_cash = "$%{value} Depôt payé avec l'argent",
        paid_with_bank = "$%{value} Depôt payé avec la banque",
        refund_to_cash = "$%{value} Depôt payé avec l'argent",
        you_earned = "Vous avez gagné $%{value}",
        payslip_time = "Vous avez fini de travailler... Temps de récupérer votre paie",
    },
    menu = {
        header = "Camions disponibles",
        close_menu = "⬅ Fermer le menu",
    },
    mission = {
        store_reached = "Vous avez atteint la destination, Récuperez une boite dans le coffre avec [E] et livrez-la au marqueur.",
        take_box = "Prenez une boite dans le coffre avec [E]",
        deliver_box = "Livrez la boite au marqueur",
        another_box = "Prenez une autre boite dans le coffre.",
        goto_next_point = "Aller au prochain point",
    },
    info = {
        deliver_e = "~g~E~w~ - Livrer la boite",
        deliver = "Livrer la boite",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

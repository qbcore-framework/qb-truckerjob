local Translations = {
    error = {
        no_deposit = "Depósito de $%{value} necessário",
        cancelled = "Cancelado",
        vehicle_not_correct = "Este não é um veículo comercial!",
        no_driver = "Você deve ser o motorista para fazer isso..",
        no_work_done = "Você ainda não fez nenhum trabalho..",
        backdoors_not_open = "As portas traseiras do veículo não estão abertas",
        get_out_vehicle = "Você precisa sair do veículo para realizar esta ação",
        too_far_from_trunk = "Você precisa pegar as caixas no porta-malas do seu veículo",
        too_far_from_delivery = "Você precisa estar mais próximo do ponto de entrega"
    },
    success = {
        paid_with_cash = "Depósito de $%{value} pago em dinheiro",
        paid_with_bank = "Depósito de $%{value} pago da conta bancária",
        refund_to_cash = "Depósito de $%{value} reembolsado em dinheiro",
        you_earned = "Você ganhou $%{value}",
        payslip_time = "Você visitou todas as lojas... Hora de receber seu contra-cheque!",
    },
    menu = {
        header = "Caminhões Disponíveis",
        close_menu = "⬅ Fechar Menu",
    },
    mission = {
        store_reached = "Loja alcançada, pegue uma caixa no porta-malas com [E] e entregue no marcador",
        take_box = "Pegar Uma Caixa de Produtos",
        deliver_box = "Entregar Caixa de Produtos",
        another_box = "Pegue outra Caixa de Produtos",
        goto_next_point = "Você entregou todos os produtos, siga para o próximo ponto",
        return_to_station = "Você entregou todos os produtos, retorne à estação",
        job_completed = "Você completou sua rota, por favor, pegue seu cheque de pagamento"
    },
    info = {
        deliver_e = "~g~E~w~ - Entregar Produtos",
        deliver = "Entregar Produtos",
    }
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

local Translations = {
    error = {
        no_deposit = "Requerimos un deposito de $%{value}",
        cancelled = "Cancelado",
        vehicle_not_correct = "¡Este no es un vehículo comercial!",
        no_driver = "Debes ser el conductor para poder hacer esto",
        no_work_done = "No has hecho ningún trabajo todavía"
    },
    success = {
        paid_with_cash = "Deposito de $%{value} pagado con efectivo",
        paid_with_bank = "Deposito de $%{value} pagado desde el banco",
        refund_to_cash = "Deposito de $%{value} devuelto en efectivo",
        you_earned = "Has ganado $%{value}",
        payslip_time = "Fuiste a todos los objetivos, ¡hora de tu pago!"
    },
    menu = {
        header = "Camionetas disponibles",
        close_menu = "⬅ Cerrar menú"
    },
    mission = {
        store_reached = "Has llegado a la tienda, toma una caja de la cajuela con [E] y entregala en el marcador",
        take_box = "Tomando caja de productos...",
        deliver_box = "Entregando caja de productos...",
        another_box = "Ve por otra caja",
        goto_next_point = "Has entregado todas las cajas, ve al siguiente punto"
    },
    info = {
        deliver_e = "[E] - Entregar productos",
        deliver = "Entregar productos",
        payslip = "Cobrar trabajos completados"
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

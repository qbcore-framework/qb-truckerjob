local Translations = {
    error = {
        no_deposit = "$%{value} Deposit Required",
        cancelled = "Cancelled",
        vehicle_not_correct = "This is not a commercial vehicle!",
        no_driver = "You must be the driver to do this..",
        no_work_done = "You haven't done any work yet..",
    },
    success = {
        paid_with_cash = "$%{value} Deposit Paid With Cash",
        paid_with_bank = "$%{value} Deposit Paid From Bank",
        refund_to_cash = "$%{value} Deposit Paid With Cash",
        you_earned = "You Earned $%{value}",
        payslip_time = "You Went To All The Shops .. Time For Your Payslip!",
    },
    menu = {
        header = "Available Trucks",
        close_menu = "⬅ Close Menu",
    },
    mission = {
        store_reached = "Store reached, get a box in the trunk with [E] and deliver to marker",
        take_box = "Take A Box Of Products",
        deliver_box = "Deliver Box Of Products",
        another_box = "Get another Box Of Products",
        goto_next_point = "You Have Delivered All Products, To The Next Point",
    },
    info = {
        deliver_e = "~g~E~w~ - Deliver Products",
        deliver = "Deliver Products",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

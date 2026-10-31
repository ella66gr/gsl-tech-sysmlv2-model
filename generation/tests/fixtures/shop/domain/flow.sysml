package TicketFlow {
    action def ServeTicket {
        doc /* A branching flow. */
        action receive;
        then check;

        action check;
        then pathA;
        then pathB;

        action pathA {
            doc /* One way. */
        }
        then finish;

        action pathB;
        then finish;

        action finish;
    }
}

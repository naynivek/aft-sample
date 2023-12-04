simple route table
    outbound (all tables)
        create 10.0.0.8 to transit
    outbound tgw
        delete /22 routes

transit route table
    outbound
        propagate to direct-connect-route-table
    direct-connect
        propagate to outbound
    shared
        delete propagate from prd
        delete propagate from nprd
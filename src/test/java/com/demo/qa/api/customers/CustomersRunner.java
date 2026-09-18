package com.demo.qa.api.customers;

import com.intuit.karate.junit5.Karate;

class CustomersRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run("customers", "customers-negative")
                .relativeTo(getClass());
    }
}

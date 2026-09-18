package com.demo.qa.api.health;

import com.intuit.karate.junit5.Karate;

class HealthRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run("health")
                .relativeTo(getClass());
    }
}

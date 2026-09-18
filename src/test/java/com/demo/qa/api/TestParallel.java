package com.demo.qa.api;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

class TestParallel {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:com/demo/qa/api")
                .outputCucumberJson(true)
                .tags("~@ignore", "~@manual")
                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    @Test
    void testSmoke() {
        Results results = Runner.path("classpath:com/demo/qa/api")
                .outputCucumberJson(true)
                .tags("@smoke")
                .parallel(3);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}

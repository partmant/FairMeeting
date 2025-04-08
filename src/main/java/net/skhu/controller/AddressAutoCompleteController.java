package net.skhu.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import net.skhu.service.AddressAutoCompleteService;

@RestController
@RequestMapping("/api")
public class AddressAutoCompleteController {

    @Autowired
    private AddressAutoCompleteService addressAutoCompleteService;

    /**
     * @param query 검색어
     * @return 자동완성 결과 리스트
     */
    @GetMapping("/address-autocomplete")
    public ResponseEntity<List<Map<String, Object>>> getAutoComplete(@RequestParam String query) {
        if(query == null || query.trim().isEmpty()){
            return ResponseEntity.badRequest().build();
        }

        List<Map<String, Object>> result = addressAutoCompleteService.getAutoComplete(query);
        if(result != null) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.status(500).build();
        }
    }
}

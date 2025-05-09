package net.skhu.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.dto.CategoryResponse;
import net.skhu.service.CategorySearchService;

@RestController
@RequestMapping("/api/category")
@RequiredArgsConstructor
public class CategorySearchController {

    private final CategorySearchService categorySearchService;

    @GetMapping("/search")
    public List<CategoryResponse> searchPlaces(
            @RequestParam String category,
            @RequestParam double x,
            @RequestParam double y
    ) {
        return categorySearchService.searchByCategory(category, x, y);	// service의 반환을 dto 객체를 반환하게 수정
    }
}

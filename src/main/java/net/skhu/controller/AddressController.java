package net.skhu.controller;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import net.skhu.service.AddressService;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AddressController {	// 좌표를 받아 해당 좌표의 주소 및 건물이름 반환

    private final AddressService addressService;

    @GetMapping("/address-name")
    public Map<String, String> getAddressName(
            @RequestParam double lat,
            @RequestParam double lng
    ) {
        return addressService.getAddressName(lat, lng);
    }
}

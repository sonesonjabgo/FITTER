package com.mk.fitter.api.namedwod.service;

import java.sql.Time;
import java.time.LocalTime;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import net.bytebuddy.asm.Advice;

import com.mk.fitter.api.common.service.JwtService;
import com.mk.fitter.api.namedwod.repository.WodRecordRepository;
import com.mk.fitter.api.namedwod.repository.WodRepository;
import com.mk.fitter.api.namedwod.repository.dto.WodDto;
import com.mk.fitter.api.namedwod.repository.dto.WodRankDto;
import com.mk.fitter.api.namedwod.repository.dto.WodRecordDto;
import com.mk.fitter.api.user.repository.UserRepository;
import com.mk.fitter.api.user.repository.dto.UserDto;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class RankServiceImpl implements RankService {

	private final WodRepository wodRepository;
	private final WodRecordRepository wodRecordRepository;
	private final JwtService jwtService;
	private final UserRepository userRepository;

	@Override
	public Page<WodRecordDto> getRanks(String wodName, Pageable pageable) throws Exception {
		WodDto wodDto = wodRepository.findByName(wodName);
		if(wodDto == null) return null;
		return wodRecordRepository.findRankById(wodDto.getId(), pageable);
	}

	@Override
	public WodRankDto getMyRank(String wodName, String accessToken) throws Exception {
		Integer uid = jwtService.extractUID(accessToken)
			.orElseThrow(() -> new Exception("getMyRank :: 유효하지 않은 access token입니다."));

		UserDto userDto = userRepository.findById(uid).orElseThrow(() -> new Exception("getMyRank :: 존재하지 않는 사용자입니다."));

		WodDto wodDto = wodRepository.findByName(wodName);
		if(wodDto == null) return null;

		//return wodRecordRepository.findRankByIdAndUserId(wodDto.getId(), userDto.getId());

		Map<String, Object> rankByIdAndUserId = wodRecordRepository.findRankByIdAndUserId(wodDto.getId(),
			userDto.getId());

		return WodRankDto.builder()
			.userDto(userDto)
			.wodDto(wodDto)
			.ranking(Integer.parseInt(String.valueOf(rankByIdAndUserId.get("ranking"))))
			.count(Integer.parseInt(String.valueOf(rankByIdAndUserId.get("count"))))
			.time(((Time)rankByIdAndUserId.get("time")).toLocalTime())
			.build();
	}
}

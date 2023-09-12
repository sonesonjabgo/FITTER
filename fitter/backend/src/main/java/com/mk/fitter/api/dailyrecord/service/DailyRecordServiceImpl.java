package com.mk.fitter.api.dailyrecord.service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.mk.fitter.api.dailyrecord.repository.DailyRecordDetailRepository;
import com.mk.fitter.api.dailyrecord.repository.DailyRecordRepository;
import com.mk.fitter.api.dailyrecord.repository.dto.DailyRecordDetailDto;
import com.mk.fitter.api.dailyrecord.repository.dto.DailyRecordDto;
import com.mk.fitter.api.user.repository.UserRepository;
import com.mk.fitter.api.user.repository.dto.UserDto;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DailyRecordServiceImpl implements DailyRecordService {

	private final DailyRecordRepository dailyRecordRepository;
	private final UserRepository userRepository;
	private final DailyRecordDetailRepository dailyRecordDetailRepository;

	@Override
	public List<DailyRecordDto> getAllRecordsByMonth(int userId, LocalDate startDate, LocalDate endDate) {
		List<DailyRecordDto> byUserIdAndDateMonth = dailyRecordRepository.findByUserDto_IdAndDateBetween(userId,
			startDate, endDate);
		return byUserIdAndDateMonth;
	}

	@Override
	public boolean writeDailyRecord(DailyRecordDto dailyRecordDto) throws Exception {
		//유저 정보 찾기 추가해야함
		Optional<UserDto> byId = userRepository.findById(dailyRecordDto.getUserDto().getId());
		if (!byId.isPresent()) {
			throw new Exception("유저가 없습니다.");
		}
		dailyRecordDto.setUserDto(byId.get());
		DailyRecordDto save = dailyRecordRepository.save(dailyRecordDto);
		for (DailyRecordDetailDto temp : dailyRecordDto.getDailyRecordDetails()) {
			temp.setDailyRecordDto(save);
			dailyRecordDetailRepository.save(temp);
		}
		return true;
	}

	@Override
	public DailyRecordDto getDailyRecordByDate(LocalDate date, int userId) {
		return dailyRecordRepository.findByDateAndUserDto_Id(date, userId);
	}

	@Override
	public boolean deleteDailyRecord(int dailyRecordId) {
		return dailyRecordRepository.deleteById(dailyRecordId);
	}

	@Override
	public boolean modifyDailyRecord(int dailyRecordId, Map<String, String> memo) throws Exception {
		Optional<DailyRecordDto> byId = dailyRecordRepository.findById(dailyRecordId);
		if (byId.isPresent()) {
			DailyRecordDto dailyRecordDto = byId.get();
			dailyRecordDto.setMemo(memo.get("memo"));
			return true;
		} else {
			throw new Exception("수정에 실패했습니다.");
		}
	}
}
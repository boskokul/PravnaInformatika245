package com.example.pravna.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.pravna.model.Verdict;
import org.springframework.data.jpa.repository.Query;

import java.util.List;


public interface VerdictsRepository extends JpaRepository<Verdict,Long> {
    @Query("select c.name from Verdict  c")
    public List<String> getAllNames();

}

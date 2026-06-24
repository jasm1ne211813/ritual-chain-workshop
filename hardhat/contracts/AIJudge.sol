// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PrivacyBounty {
    struct Bounty {
        address creator;       // 대회를 연 사람
        uint256 deadline;      // 제출 마감 시간
        bool isFinalized;      // 1등이 뽑혔는지 여부
        mapping(address => bytes32) commitments; // 사람들이 낸 비밀 상자
        mapping(address => string) revealedAnswers; // 상자를 열어서 나온 진짜 정답
        address[] participants; // 참가자 명단
    }

    uint256 public bountyCount;
    mapping(uint256 => Bounty) public bounties;

    // 1단계: "비밀 상자" 제출하기 (정답과 비밀번호를 섞은 '해시값'만 제출)
    function submitCommitment(uint256 bountyId, bytes32 commitment) external {
        Bounty storage bounty = bounties[bountyId];
        require(block.timestamp < bounty.deadline, "Submission phase over");
        
        // 처음 제출하는 사람만 명단에 추가
        if (bounty.commitments[msg.sender] == bytes32(0)) {
            bounty.participants.push(msg.sender);
        }
        
        bounty.commitments[msg.sender] = commitment;
    }

    // 2단계: "상자 열기" (마감이 끝난 후, 진짜 정답과 비밀번호를 제출해서 확인)
    function revealAnswer(uint256 bountyId, string calldata answer, bytes32 salt) external {
        Bounty storage bounty = bounties[bountyId];
        require(block.timestamp >= bounty.deadline, "Still in submission phase");
        require(bounty.commitments[msg.sender] != bytes32(0), "No commitment found");

        // 내가 낸 정답, 비밀번호, 주소, 대회ID를 다 같이 믹서기에 넣고 돌려봅니다.
        bytes32 expectedCommitment = keccak256(abi.encodePacked(answer, salt, msg.sender, bountyId));
        
        // 처음에 냈던 비밀 상자랑 똑같은지 확인해요! (다르면 탈락)
        require(expectedCommitment == bounty.commitments[msg.sender], "Invalid reveal");

        bounty.revealedAnswers[msg.sender] = answer;
    }

    // 3단계: AI 채점을 위해 정답 목록을 싹 모아서 보내기
    function judgeAll(uint256 bountyId, bytes calldata llmInput) external pure returns (string memory) {
        // 실제 구현 시에는 이 함수에서 Ritual AI 노드에게 "이 정답들 채점해줘!"라고 요청해요.
        // 과제용으로는 기본 틀만 유지해 주면 됩니다.
        return "AI Judging requested";
    }

    // 4단계: 최종 1등 확정하기
    function finalizeWinner(uint256 bountyId, uint256 winnerIndex) external {
        Bounty storage bounty = bounties[bountyId];
        require(!bounty.isFinalized, "Already finalized");
        
        bounty.isFinalized = true;
        // winnerIndex에 해당하는 참가자가 상금을 받게 처리해요.
    }
}

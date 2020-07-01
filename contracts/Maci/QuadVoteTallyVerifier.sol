// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// 2019 OKIMS

pragma solidity ^0.5.0;

import "./Pairing.sol";

contract QuadVoteTallyVerifier {

    using Pairing for *;

    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[10] IC;
    }

    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(16810519898949450491144849877708909431501378155320089664294574740831980631303), uint256(7895694398644173672814439342505960452720659724325499035310661816903982692504));
        vk.beta2 = Pairing.G2Point([uint256(68559242197473637070854033153288451335287977055407813237605437393442781527), uint256(5727713150359564087502718012495621713794672871404901769564802037400711916388)], [uint256(3178198125216786261225745421746777265024885613187886458170264105478111866347), uint256(18839108565499807135376922950101855085244159167560921965731127293734257876352)]);
        vk.gamma2 = Pairing.G2Point([uint256(19711035991483007653339664960145797649954055120187829113908613386311606206023), uint256(5139586755849051224348380469413587247530250333995560119411640690547015359506)], [uint256(10745145045218307516676492777377642043170750742195861197304254546212079434489), uint256(17672994891891713193612407289996051928053103383579507846631178617344948543149)]);
        vk.delta2 = Pairing.G2Point([uint256(12545989317023536419697675381846851670859187693813718412802274431351516418036), uint256(2096942640878756109219043798087981353527907292932654942113183039250156944146)], [uint256(9882413107765655163922037517694446983442891617003973622266085057959061161057), uint256(3678552723351520518613101525143392330663730670148082256288327617027676583218)]);
        vk.IC[0] = Pairing.G1Point(uint256(15134490981206708247558619698080506093218168811497164421775165962234927775401), uint256(15982858508347791226626177932838996445497855900519175564093365193838530485922));
        vk.IC[1] = Pairing.G1Point(uint256(2216915217076477825216662182771286103717106552379146341182451575175535617726), uint256(1877826558579739896952110738359421574719638628635098085029531078686448209231));
        vk.IC[2] = Pairing.G1Point(uint256(10294513745597836741675257875663515117385204667185622716812290731710631894527), uint256(12357585551234489212606251634281487203512280010381139024183512452199295729858));
        vk.IC[3] = Pairing.G1Point(uint256(149517763689396908727852491511360362734876964876492659230091158623978671477), uint256(5792927949631488998181491804612390381466576152451616966610871580730419050356));
        vk.IC[4] = Pairing.G1Point(uint256(15828330601742072230732002743905507259052466017103244681354831029596260117758), uint256(9854916441063970639000245874624434975398691395440743532487865104966571780200));
        vk.IC[5] = Pairing.G1Point(uint256(15206405604925032132811998236859273746740458679562484270319219667621467396576), uint256(4980795002133828837038559854527597621682545145914902999995560798824064606771));
        vk.IC[6] = Pairing.G1Point(uint256(17459223520070797372024468074581209503863697668591616653122465576506904286015), uint256(495441143833446004979938582787468013989041879287162696150738988712896552668));
        vk.IC[7] = Pairing.G1Point(uint256(19083789163518321970161375189324550451767448551272067365600715253448792001319), uint256(3599088891896895818238891675742115330557145616593471994993605582289097478083));
        vk.IC[8] = Pairing.G1Point(uint256(18398978092968421907264987550249156040865660294695294059925229302433940628039), uint256(21844013555187931577185622603581293473362249304846132743045321479557046037500));
        vk.IC[9] = Pairing.G1Point(uint256(19383270524825360401604477624808974444578921083598219854345119805007633621780), uint256(8654982732012983953323932632638282656295252678301340393470317737531253063135));

    }
    
    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[9] memory input
    ) public view returns (bool) {

        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);

        VerifyingKey memory vk = verifyingKey();

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

        // Make sure that proof.A, B, and C are each less than the prime q
        require(proof.A.X < PRIME_Q, "verifier-aX-gte-prime-q");
        require(proof.A.Y < PRIME_Q, "verifier-aY-gte-prime-q");

        require(proof.B.X[0] < PRIME_Q, "verifier-bX0-gte-prime-q");
        require(proof.B.Y[0] < PRIME_Q, "verifier-bY0-gte-prime-q");

        require(proof.B.X[1] < PRIME_Q, "verifier-bX1-gte-prime-q");
        require(proof.B.Y[1] < PRIME_Q, "verifier-bY1-gte-prime-q");

        require(proof.C.X < PRIME_Q, "verifier-cX-gte-prime-q");
        require(proof.C.Y < PRIME_Q, "verifier-cY-gte-prime-q");

        // Make sure that every input is less than the snark scalar field
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < SNARK_SCALAR_FIELD,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.plus(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }

        vk_x = Pairing.plus(vk_x, vk.IC[0]);

        return Pairing.pairing(
            Pairing.negate(proof.A),
            proof.B,
            vk.alfa1,
            vk.beta2,
            vk_x,
            vk.gamma2,
            proof.C,
            vk.delta2
        );
    }
}

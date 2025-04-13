// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";









interface ITokenMinter {
    function mintTo(address to, uint256 amount) external;
}






interface ICoincapsule {
    function addModule(uint256 tokenId, address module) external;
}




interface IWalletModule {
    /// @notice Executes arbitrary logic in the context of the wallet
    /// @param tokenId The wallet tokenId (serves as wallet identity)
    /// @param data Encoded function call or action to perform
    /// @return result Return data from execution
    function execute(uint256 tokenId, bytes calldata data) external returns (bytes memory result);
    function executeModuleFunction(bytes calldata data) external returns (bytes memory);

    /// @notice Returns a list of function selectors this module supports
    /// @dev Used to declare which actions this module can handle
    /// @return selectors List of function selectors (bytes4)
    function supportedFunctions() external view returns (bytes4[] memory);

    /// @notice Returns true if this module supports a specific function selector
    /// @param selector The function selector to query
    /// @return isSupported True if the module supports the selector
    function supportsFunction(bytes4 selector) external view returns (bool isSupported);

    /// @notice Hook that runs when a module is added to a wallet
    /// @param tokenId The wallet tokenId
    function onInstall(uint256 tokenId) external;

    /// @notice Hook that runs when a module is removed from a wallet
    /// @param tokenId The wallet tokenId
    function onUninstall(uint256 tokenId) external;

    /// @notice Returns human-readable metadata for this module
    /// @return name Name of the module
    /// @return version Semantic version (e.g. "1.0.0")
    /// @return author Address or string representing the author
    function moduleInfo() external view returns (string memory name, string memory version, string memory author);

    /// @notice Optional role-based authorization for this module
    /// @dev Can be used by modules that implement their own ACL or permission layer
    /// @param tokenId Wallet tokenId
    /// @param user Address attempting to perform an action
    /// @param action The encoded action or function selector
    /// @return allowed True if the user is allowed
    function isAuthorized(uint256 tokenId, address user, bytes4 action) external view returns (bool allowed);
}


interface IStakingToken { function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); function balanceOf(address account) external view returns (uint256); }

interface ICapsuleWallet { function getOwner(uint256 tokenId) external view returns (address); function getETHBalance(uint256 tokenId) external view returns (uint256); function getLabel(uint256 tokenId) external view returns (string memory); function depositETH(uint256 tokenId) external payable; function withdrawETH(uint256 tokenId, uint256 amount) external; }

interface ICapsuleWalletExtended is ICapsuleWallet { function walletId() external view returns (uint256); }

interface IDroneRegistry { function verifyDroneData( uint256 tokenId, uint256 trustScore, uint256 performanceMetric, bytes32[] calldata proof ) external view returns (bool); }

interface IOracleDrone { function assignTask(uint256 droneId, string calldata taskType, string calldata parameters) external returns (uint256); function completeTask(uint256 taskId) external; function executeTask(uint256 taskId) external returns (bool); function collectNoise(uint256[] calldata noiseValues) external; function commitToRandomNumber(bytes32 _commitment) external; function revealRandomNumber(uint256 _randomNumber, uint256 _nonce) external; function getRandomNumber(address user) external view returns (uint256); function emergencyRebalance() external; function setOracleManager(address _oracleManager) external; function depositToWallet() external payable; function withdrawFromWallet(uint256 amount) external; function getOracleManager() external view returns (address); }

interface IUnifiedOracleDroneExtended is IOracleDrone {}

interface ITaskManager { function assignTask(uint256 droneId, string calldata taskType, string calldata parameters) external returns (uint256); function completeTask(uint256 taskId) external; function executeTask(uint256 taskId) external returns (bool); }

interface IRandomnessManager { function commitToRandomNumber(bytes32 _commitment) external; function revealRandomNumber(uint256 _randomNumber, uint256 _nonce) external; function getRandomNumber(address user) external view returns (uint256); function collectNoise(uint256[] calldata noiseValues) external; }

interface IPriceAggregator { function registerProvider(address provider) external; function updateProvider(address provider, bool isActive) external; function submitData(bytes32 asset, uint256 price) external returns (bool); function getPrice(bytes32 asset) external view returns (uint256); }

interface IArbitrage { function executeFlashLoan(address token, uint256 amount) external; }

interface ICurvePool { function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256); function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256); }

interface ILending { function depositCollateral(address user, uint256 amount) external; function withdrawCollateral(address user, uint256 amount) external; function liquidate(address user) external; }

interface IGovernance { function voteOnProposal(uint256 proposalId, bool support) external; function executeProposal(uint256 proposalId) external; }

interface ILiquidityAggregator { function getBestLiquiditySource(address token, uint256 amount) external view returns (address, uint256); function borrowLiquidity(address source, address token, uint256 amount) external; }

interface IOracle { function submitData(bytes32 asset, uint256 price) external returns (bool); }

interface IStaking { function stake(address user, uint256 amount) external; function unstake(address user, uint256 amount) external; }

library Create3 {
 function cloneAndDeploy(bytes32 salt) internal returns (address) {
        address implementation = 0x587050B41391cDa8235aF3C4F8260098b69704A7; // Replace with your base wallet implementation address
        address clone = Clones.cloneDeterministic(implementation, salt);
        return clone;
    }
}

library Create4 {
    function cloneAndDeploy(bytes32 salt) internal returns (address) {
        address implementation = 0x987309bB0ab7AaEEd4164Ca3c6D9dd69D2239602; // Replace with your oracle implementation address
        address clone = Clones.cloneDeterministic(implementation, salt);
        return clone;
    }
}

interface IDexPool {
    function initialize(address tokenA, address tokenB) external;
    function swap(
        address tokenIn, 
        uint256 amountIn, 
        uint256 leverage, 
        bytes32[] calldata proof,
        bytes32 leaf
    ) external;
}




library MerkleLib {
    // Function to verify Merkle proof
    function verifyMerkleProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            computedHash = (computedHash < proofElement) 
                ? keccak256(abi.encodePacked(computedHash, proofElement))
                : keccak256(abi.encodePacked(proofElement, computedHash));
        }

        return computedHash == root;
    }
}

library SignatureLib {
    // Function to recover signer from a message and signature
    function recoverSigner(bytes32 message, bytes memory signature) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(message, v, r, s);
    }

    // Split the signature into its r, s, and v components
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
contract ModularExecutor {

    using Clones for address;

    bytes32 public merkleRoot;
    address public dao;
    address[] public modules;

    struct FunctionData {
        bytes32 selector;
        bytes32[] proof;
    }

    mapping(bytes32 => address) public deployedModules;
    mapping(bytes32 => address) public proxyInstances;
    bytes32[] public allDeployedModules; // Array to track all deployed module hashes
    mapping(bytes32 => bool) public daoOnlyModules; // Optional access control for DAO-only modules
    mapping(address => mapping(bytes32 => FunctionData)) public functionSelectors;

    event ModuleExecuted(address indexed caller, bytes32 indexed bytecodeHash, address proxy);
    event MerkleRootUpdated(bytes32 newRoot);
    event ModuleDeployed(bytes32 indexed bytecodeHash, address implementation, address proxy);

    modifier onlyDAO() {
        require(msg.sender == dao, "Not DAO");
        _;
    }

    constructor(bytes32 _merkleRoot, address _dao) {
        merkleRoot = _merkleRoot;
        dao = _dao;
    }

    function updateMerkleRoot(bytes32 _newRoot) external onlyDAO {
        merkleRoot = _newRoot;
        emit MerkleRootUpdated(_newRoot);
    }

    function setDaoOnlyModule(bytes32 bytecodeHash, bool enabled) external onlyDAO {
        daoOnlyModules[bytecodeHash] = enabled;
    }

    function executeWithSignature(
        bytes memory moduleBytecode,
        bytes memory callData,
        bytes32[] calldata proof,
        bytes memory signature
    ) external payable {
        bytes32 message = keccak256(abi.encodePacked(moduleBytecode, callData));
        address signer = SignatureLib.recoverSigner(message, signature);
        require(signer == dao, "Signer not authorized");

        bytes32 bytecodeHash = keccak256(moduleBytecode);
        require(MerkleLib.verifyMerkleProof(proof, merkleRoot, bytecodeHash), "Invalid proof");

        address implementation = deployedModules[bytecodeHash];
        address proxy = proxyInstances[bytecodeHash];

        if (implementation == address(0)) {
            assembly {
                implementation := create(0, add(moduleBytecode, 0x20), mload(moduleBytecode))
            }
            require(implementation != address(0), "Deployment failed");
            deployedModules[bytecodeHash] = implementation;
            allDeployedModules.push(bytecodeHash);
        }

        if (proxy == address(0)) {
            proxy = implementation.clone();
            proxyInstances[bytecodeHash] = proxy;
            emit ModuleDeployed(bytecodeHash, implementation, proxy);
        }

        (bool success, bytes memory result) = proxy.call{value: msg.value}(callData);
        require(success, string(result));

        emit ModuleExecuted(msg.sender, bytecodeHash, proxy);
    }

    function addModule(
        address implementation,
        bytes memory moduleBytecode,
        bytes32[] calldata proof
    ) external onlyDAO {
        bytes32 bytecodeHash = keccak256(moduleBytecode);
        require(MerkleLib.verifyMerkleProof(proof, merkleRoot, bytecodeHash), "Invalid Merkle proof");
        require(deployedModules[bytecodeHash] == address(0), "Already exists");
        deployedModules[bytecodeHash] = implementation;
        allDeployedModules.push(bytecodeHash);
        emit ModuleDeployed(bytecodeHash, implementation, address(0));
    }

    function addModuleWithProxy(
        address implementation,
        bytes memory moduleBytecode,
        bytes32[] calldata proof
    ) external onlyDAO {
        bytes32 bytecodeHash = keccak256(moduleBytecode);
        require(MerkleLib.verifyMerkleProof(proof, merkleRoot, bytecodeHash), "Invalid Merkle proof");
        require(deployedModules[bytecodeHash] == address(0), "Already exists");

        deployedModules[bytecodeHash] = implementation;
        address proxy = implementation.clone();
        proxyInstances[bytecodeHash] = proxy;
        allDeployedModules.push(bytecodeHash);

        emit ModuleDeployed(bytecodeHash, implementation, proxy);
    }

    function batchAddModules(
        address[] calldata implementations,
        bytes[] calldata bytecodes,
        bytes32[][] calldata proofs
    ) external onlyDAO {
        require(
            implementations.length == bytecodes.length && bytecodes.length == proofs.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < implementations.length; i++) {
            this.addModule(implementations[i], bytecodes[i], proofs[i]);
        }
    }

    function addFunctionSelector(address _contract, bytes32 _selector, bytes32[] memory _proof) external {
        functionSelectors[_contract][_selector] = FunctionData({
            selector: _selector,
            proof: _proof
        });
    }

    // New function to add multiple function selectors
    function addFunctionSelectorsFromData(
        bytes[] memory _contractData,
        bytes32[][] memory _selectors,
        bytes32[][] memory _proofs
    ) external {
        require(
            _contractData.length == _selectors.length && _selectors.length == _proofs.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < _contractData.length; i++) {
            for (uint256 j = 0; j < _selectors[i].length; j++) {
                this.addFunctionSelector(address(uint160(uint256(keccak256(_contractData[i])))), _selectors[i][j], _proofs[i]);
            }
        }
    }

    function verifySelector(bytes32[] memory _proof, bytes32 _leaf) public view returns (bool) {
        bytes32 computedHash = _leaf;
        for (uint i = 0; i < _proof.length; i++) {
            computedHash = _proof[i] < computedHash 
                ? keccak256(abi.encodePacked(_proof[i], computedHash)) 
                : keccak256(abi.encodePacked(computedHash, _proof[i]));
        }
        return computedHash == merkleRoot;
    }

    function execute(
        bytes memory moduleBytecode,
        bytes memory callData,
        bytes32[] calldata proof
    ) external payable {
        bytes32 bytecodeHash = keccak256(moduleBytecode);
        require(MerkleLib.verifyMerkleProof(proof, merkleRoot, bytecodeHash), "Invalid proof");

        if (daoOnlyModules[bytecodeHash]) {
            require(msg.sender == dao, "DAO only module");
        }

        address implementation = deployedModules[bytecodeHash];
        address proxy = proxyInstances[bytecodeHash];

        if (implementation == address(0)) {
            assembly {
                implementation := create(0, add(moduleBytecode, 0x20), mload(moduleBytecode))
            }
            require(implementation != address(0), "Deployment failed");
            deployedModules[bytecodeHash] = implementation;
            allDeployedModules.push(bytecodeHash);
        }

        if (proxy == address(0)) {
            proxy = implementation.clone();
            proxyInstances[bytecodeHash] = proxy;
            emit ModuleDeployed(bytecodeHash, implementation, proxy);
        }

        (bool success, bytes memory result) = proxy.call{value: msg.value}(callData);
        require(success, string(result));

        emit ModuleExecuted(msg.sender, bytecodeHash, proxy);
    }

    function getAllDeployedModules() external view returns (bytes32[] memory) {
        return allDeployedModules;
    }

    function getDeployedModule(bytes32 bytecodeHash) external view returns (address) {
        return deployedModules[bytecodeHash];
    }

    function getProxyInstance(bytes32 bytecodeHash) external view returns (address) {
        return proxyInstances[bytecodeHash];
    }
}

interface IDeFiModule {
    function runStrategy(address executor, bytes calldata data) external payable;
}

interface IUniswapV2Router {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract UniswapV2Swap is IDeFiModule {
    // Use the SushiSwap Router on Arbitrum One:
    address public constant UNISWAP_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    event SwapExecuted(address indexed from, address indexed to, uint amountOutMin, address[] path, uint deadline);
    event SwapExecuted(uint tokenAmountReceived);

    function runStrategy(address, bytes calldata data) external payable override {
        (uint amountOutMin, address[] memory path, address to, uint deadline) =
            abi.decode(data, (uint, address[], address, uint));

        // Get the amounts array returned by swapExactETHForTokens
        uint[] memory amounts = IUniswapV2Router(UNISWAP_ROUTER).swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            to,
            deadline
        );

        // Log the amount of tokens received from the swap
        emit SwapExecuted(amounts[amounts.length - 1]);
    }
}
contract FundsVault is Ownable {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public balances; // Track balances of each address
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed receiver, uint256 amount);

    constructor() Ownable(msg.sender) {}

    // Deposit funds (ETH or ERC20 tokens)
    function deposit() external payable {
        require(msg.value > 0, "Must send ETH to deposit");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function depositERC20(address token, uint256 amount) external {
        require(amount > 0, "Must send tokens to deposit");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        balances[token] += amount;
        emit Deposit(msg.sender, amount);
    }

    // Withdraw funds (ETH or ERC20 tokens)
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function withdrawERC20(address token, uint256 amount) external {
        require(balances[token] >= amount, "Insufficient funds");
        balances[token] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }

    // Allow contract to transfer ownership of vault
    function transferVaultOwnership(address newOwner) external onlyOwner {
        transferOwnership(newOwner);
    }

    receive() external payable {}
}


contract Coincapsule is ERC20, Ownable, ReentrancyGuard {
    using Address for address;
    using Address for address payable;
    using SafeERC20 for IERC20;
    address public capsuleContract;

    uint256 public currentTokenId;

    struct Metadata {
        string name;
        uint256 priceInWei; // Assuming you want to store the price of a token.
    }

    struct Wallet {
        address owner;
        string label;
        bool frozen;
        address wallet;
        uint256 ethBalance;
        uint tokenId;
    }

    struct TokenDetails {
        address walletAddress;
        address oracleAddress;
        uint256 tokenId;
        string label; // Adding label field
    }

   struct Message {
    address sender;
    uint256 fromCapsuleId;
    uint256 toCapsuleId;
    uint256 timestamp;
    string content;
}

mapping(uint256 => Message[]) private capsuleInbox;

   event CapsuleMessageSent(
    address indexed sender,
    uint256 indexed fromCapsuleId,
    uint256 indexed toCapsuleId,
    string content,
    uint256 timestamp
);
    mapping(address => Metadata) public metadataByAddress;

    // Mapping to store minted ERC20 tokens by tokenId
    mapping(uint256 => uint256) public mintedTokens;

    event OracleCreated(uint256 indexed tokenId, address indexed oracleAddress);
    event TokenMinted(uint256 tokenId, uint256 amount);

    uint256 public constant MAX_SUPPLY = 13000000000;
    uint8 public constant DECIMALS = 0;
    uint256 public constant MAX_MINT_AMOUNT = 100;
    uint256 public constant MINT_FEE = 0.0001 ether;

    address public feeVault;

    enum TwinWalletType { PRIMARY, SECONDARY }

    mapping(uint256 => mapping(bytes4 => address)) public walletModules;
    mapping(uint256 => mapping(bytes4 => bool)) public moduleEnabled;
    mapping(uint256 => mapping(TwinWalletType => Wallet)) public tokenWallets;
    mapping(address => uint256[]) public ownerToTokenIds;
    mapping(address => mapping(uint256 => uint256)) private ownerTokenIndex;
    mapping(uint256 => bytes32) private walletPasswords;
    mapping(uint256 => address) public oracleDrones;
    mapping(uint256 => bytes32) public walletMerkleRoots;
    mapping(uint256 => mapping(bytes4 => address)) public moduleSelectors;
    mapping(uint256 => address) public tokenIdToOracle;
    mapping(uint256 => mapping(string => address)) public linkedContracts;
    mapping(uint256 => TokenDetails) public tokenDetails;
    mapping(address => bool) public trustedModules;

    uint256 public totalMinted;

    event WalletCreated(uint256 tokenId, address walletAddress, string label);
    event WalletFrozen(uint256 indexed tokenId, TwinWalletType walletType);
    event WalletUnfrozen(uint256 indexed tokenId, TwinWalletType walletType);
    event ETHDeposited(uint256 indexed tokenId, TwinWalletType walletType, address indexed from, uint256 amount);
    event ETHWithdrawn(uint256 indexed tokenId, TwinWalletType walletType, address indexed to, uint256 amount);
    event ModuleAdded(uint256 indexed tokenId, address indexed module);
    event OracleDeployed(uint256 indexed tokenId, address oracle);

    modifier onlyWalletOwner(uint256 tokenId, TwinWalletType walletType) {
        require(tokenWallets[tokenId][walletType].owner == msg.sender, "Not the wallet owner");
        _;
    }

    modifier notFrozen(uint256 tokenId, TwinWalletType walletType) {
        require(!tokenWallets[tokenId][walletType].frozen, "Wallet is frozen");
        _;
    }

    modifier onlyTrustedModule(address module) {
        require(trustedModules[module], "Untrusted module");
        _;
    }

    constructor(address _feeVault) ERC20("Iconoclast Commander", "ICMR") Ownable(msg.sender) {
        require(_feeVault != address(0), "Invalid fee vault address");
        feeVault = _feeVault;
        currentTokenId = 1;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

   function sendMessage(
    uint256 fromCapsuleId,
    uint256 toCapsuleId,
    string calldata content
) external {
    // Ensure the sender is the owner of the sending capsule.
    require(IERC721(capsuleContract).ownerOf(fromCapsuleId) == msg.sender, "Not capsule owner");

    // Make sure that the message content is not empty.
    require(bytes(content).length > 0, "Message content empty");

    // Create a new message.
    Message memory newMessage = Message({
        sender: msg.sender,
        fromCapsuleId: fromCapsuleId,
        toCapsuleId: toCapsuleId,
        timestamp: block.timestamp,
        content: content
    });

    // Store the message in the recipient's inbox.
    capsuleInbox[toCapsuleId].push(newMessage);

    // Emit an event to record that a message was sent.
    emit CapsuleMessageSent(msg.sender, fromCapsuleId, toCapsuleId, content, block.timestamp);
}

    // ----------------- Core Wallet Logic ------------------

    // Function to mint tokens, create wallet, and create oracle for each tokenId
    function mintTokenAndCreateWalletAndOracle(uint256 amount, string memory label) external payable nonReentrant  {
        require(totalMinted + amount <= MAX_SUPPLY, "Exceeds max supply");
        require(msg.value >= MINT_FEE * amount, "Insufficient mint fee");

        (bool feeSent, ) = feeVault.call{ value: MINT_FEE * amount }("");
        require(feeSent, "Fee transfer failed");

        for (uint256 i = 1; i <= amount; i++) {
            uint256 tokenId = totalMinted + i;
            _mint(msg.sender, 1);

            address wallet = this.createWallet(tokenId); 
            address oracleAddress = this.createOracle(tokenId);
            ownerToTokenIds[msg.sender].push(tokenId);
            ownerTokenIndex[msg.sender][tokenId] = ownerToTokenIds[msg.sender].length - 1;

            // Store token details
            tokenDetails[tokenId] = TokenDetails({
                walletAddress: wallet,
                oracleAddress: oracleAddress,
                tokenId: tokenId,
                label: label
            });

            // Emit events
            emit WalletCreated(tokenId, wallet, label);
            emit OracleCreated(tokenId, oracleAddress);
            emit TokenMinted(tokenId, amount);

            // Increment the tokenId for the next mint
            currentTokenId++;
        }
    }

    // Private function to create a new wallet for each tokenId
    function createWallet(uint256 tokenId) external returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(tokenId, msg.sender, block.timestamp));
        address wallet = Create3.cloneAndDeploy(salt);
        return wallet;
    }

    // Private function to create an oracle for each tokenId
    function createOracle(uint256 tokenId) external returns (address) {
        bytes32 salt = keccak256(abi.encodePacked("oracle", tokenId, msg.sender, block.timestamp));
        address oracle = Create4.cloneAndDeploy(salt);
        return oracle;
    }

    function addModule(uint256 tokenId, address module) external onlyOwner {
        require(module != address(0), "Invalid module");
        require(IWalletModule(module).supportedFunctions().length > 0, "No supported functions");

        walletModules[tokenId][bytes4(keccak256(abi.encodePacked("add_module")))] = module;

        emit ModuleAdded(tokenId, module);

        bytes4[] memory selectors = IWalletModule(module).supportedFunctions();
        for (uint i = 0; i < selectors.length; i++) {
            moduleSelectors[tokenId][selectors[i]] = module;
        }
    }

    function getTokenFullDetails(uint256 tokenId) external view returns (
        address walletAddress, 
        address oracleAddress, 
        string memory label, 
        uint256 tokenBalance
    ) {
        TokenDetails memory details = tokenDetails[tokenId];
        Wallet memory wallet = tokenWallets[tokenId][TwinWalletType.PRIMARY];
        return (details.walletAddress, details.oracleAddress, details.label, balanceOf(wallet.wallet));
    }

    function _createTwinWallet(
        uint256 tokenId, 
        address walletAddress, 
        string memory label, 
        TwinWalletType walletType
    ) internal {
        tokenWallets[tokenId][walletType] = Wallet({
            owner: owner(),
            label: label,
            frozen: false,
            wallet: address(0),
            ethBalance: 0,
            tokenId: tokenId
        });

        emit WalletCreated(tokenId, walletAddress, label);
    }

    // ------------------ View ------------------

    function getTokenDetails(uint256 tokenId) external view returns (
        address walletAddress, 
        address oracleAddress, 
        string memory label
    ) {
        TokenDetails memory details = tokenDetails[tokenId];
        return (details.walletAddress, details.oracleAddress, details.label);
    }

    function getWalletDetails(uint256 tokenId, TwinWalletType walletType) external view returns (
        address owner, 
        string memory label, 
        bool frozen, 
        address wallet, 
        uint256 ethBalance
    ) {
        Wallet memory walletDetails = tokenWallets[tokenId][walletType];
        return (walletDetails.owner, walletDetails.label, walletDetails.frozen, walletDetails.wallet, walletDetails.ethBalance);
    }

    function getTokensOwnedBy(address owner) external view returns (uint256[] memory) {
        return ownerToTokenIds[owner];
    }
}
contract OracleContract is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address payable;
    using SafeERC20 for IERC20;
    address oracleAddress;
    address public strategy;
    uint256 public lastValue;
    string public dataLabel;
      mapping(address => bytes32) public merkleRoots;

       event MerkleRootUpdated(address indexed user, bytes32 newRoot);
       event VerifiedAction(address indexed user, string actionType);



    // ---------------- Decoding Utilities ----------------
    event DecodedEvent(uint256 indexed id, address indexed addr, string data);
       event OracleUpdated(uint256 newValue, string label);

    struct DecodedTransaction {
        address from;
        address to;
        uint256 value;
        uint256 gasLimit;
        uint256 nonce;
        bytes data;
        bytes signature;
    }
    struct DecodedTuple {
        uint256 num;
        address addr;
        string text;
        bytes extraData;
    }
    struct DecodedStruct {
        uint256 id;
        address owner;
        uint256 balance;
    }
    struct DecodedKeyValue {
        bytes32 key;
        bytes value;
    }

    struct Shard { uint256 id; bytes32 asset; uint256 price; }

mapping(uint256 => Shard) public shards;
uint256 public totalShards;

event ShardCreated(uint256 indexed id, bytes32 asset, uint256 price);






    constructor(string memory label) Ownable(msg.sender) {
        dataLabel = label;
    }
  function createShard(bytes32 asset, uint256 price) external onlyOwner {
        shards[totalShards] = Shard({
            id: totalShards,
            asset: asset,
            price: price
        });
        emit ShardCreated(totalShards, asset, price);
        totalShards++;
    }

   

    // ------------------ Wallet and Oracle Drone Creation -------------------
    function createWalletAndOracle(uint256 walletId, address owner, string calldata label, address oracleDrone) external onlyOwner {
        require(wallets[walletId].owner == address(0), "Wallet already exists");
        
        wallets[walletId] = WalletData({
            owner: owner,
            label: label,
            frozen: false,
            ethBalance: 0
        });

        walletOracles[walletId] = oracleDrone;
        
        totalMinted++;
        emit WalletAndOracleCreated(walletId, owner, label, oracleDrone);
    }

    function createWallet(uint256 walletId, address owner, string calldata label) external onlyOwner {
        require(wallets[walletId].owner == address(0), "Wallet already exists");

        wallets[walletId] = WalletData({
            owner: owner,
            label: label,
            frozen: false,
            ethBalance: 0
        });

        totalMinted++;
        emit WalletCreatedAndOracleDroneInstantiated(walletId, totalMinted);
    }

    function registerMerkleRoot(bytes32 root) external {
        merkleRoots[msg.sender] = root;
        emit MerkleRootUpdated(msg.sender, root);
    }

    function verifyAction(address user, bytes32 leaf, bytes32[] calldata proof) internal view returns (bool) {
        require(merkleRoots[user] != bytes32(0), "User not registered");
        return MerkleProof.verify(proof, merkleRoots[user], leaf);
    }

    function authenticateWallet(uint256 tokenId, bytes32[] calldata proof, bytes32 leaf) external returns (bool) {
        require(verifyAction(msg.sender, leaf, proof), "Invalid Merkle proof");
        onWalletAuthenticated(msg.sender, "Wallet Authentication");
        return true;
    }

    function onWalletAuthenticated(address user, string memory actionType) internal {
        emit VerifiedAction(user, actionType);
    }

    // ------------------- Oracle Data Handling -------------------
    function submitOracleData(
        address oracle,
        bytes32 asset,
        uint256 price,
        bytes32[] calldata proof,
        bytes32 leaf
    ) external nonReentrant {
        require(verifyAction(msg.sender, leaf, proof), "Invalid proof");
        require(IOracle(oracle).submitData(asset, price), "Oracle submission failed");
        emit VerifiedAction(msg.sender, "Oracle Data Submission");
    }

    // ------------------- Task Management -------------------
    function completeComputeTask(
        address taskManager,
        uint256 taskId,
        bytes32[] calldata proof,
        bytes32 leaf
    ) external nonReentrant {
        require(verifyAction(msg.sender, leaf, proof), "Invalid proof");
        ITaskManager(taskManager).completeTask(taskId);
        emit VerifiedAction(msg.sender, "Compute Task Completed");
    }

    // ------------------- Arbitrage Execution -------------------
    function executeArbitrage(
        address arbitrageModule,
        address token,
        uint256 amount,
        bytes32[] calldata proof,
        bytes32 leaf
    ) external nonReentrant {
        require(verifyAction(msg.sender, leaf, proof), "Invalid proof");
        IArbitrage(arbitrageModule).executeFlashLoan(token, amount);
        emit VerifiedAction(msg.sender, "Arbitrage Executed");
    }

    // ------------------- Collateral Management -------------------
    function depositCollateral(
        address lendingModule,
        uint256 amount,
        bytes32[] calldata proof,
        bytes32 leaf
    ) external nonReentrant {
        require(verifyAction(msg.sender, leaf, proof), "Invalid proof");
        ILending(lendingModule).depositCollateral(msg.sender, amount);
        emit VerifiedAction(msg.sender, "Collateral Deposited");
    }

    function withdrawCollateral(
        address lendingModule,
        uint256 amount,
        bytes32[] calldata proof,
        bytes32 leaf
    ) external nonReentrant {
        require(verifyAction(msg.sender, leaf, proof), "Invalid proof");
        ILending(lendingModule).withdrawCollateral(msg.sender, amount);
        emit VerifiedAction(msg.sender, "Collateral Withdrawn");
    }

    // ------------------- Governance -------------------
    function voteOnProposal(
        address governanceModule,
        uint256 proposalId,
        bool support,
        bytes32[] calldata proof,
        bytes32 leaf
    ) external nonReentrant {
        require(verifyAction(msg.sender, leaf, proof), "Invalid proof");
        IGovernance(governanceModule).voteOnProposal(proposalId, support);
        emit VerifiedAction(msg.sender, "Voted on Proposal");
    }

    // ------------------- Strategy Execution -------------------
    function executeStrategy() external onlyOwner returns (bytes memory result) {
        require(strategy != address(0), "Strategy not set");
        (bool success, bytes memory data) = strategy.call(
            abi.encodeWithSignature("run(uint256)", lastValue)
        );
        require(success, "Strategy call failed");
        return data;
    }

    // ------------------- Utility Functions -------------------
    function decodeTuple(bytes memory data) public pure returns (DecodedTuple memory) {
        require(data.length > 64, "Data too short");
        (uint256 num, address addr, string memory text, bytes memory extraData) = abi.decode(data, (uint256, address, string, bytes));
        return DecodedTuple(num, addr, text, extraData);
    }

    function decodeStruct(bytes memory data) public pure returns (DecodedStruct memory) {
        require(data.length >= 64, "Data too short");
        (uint256 id, address owner, uint256 balance) = abi.decode(data, (uint256, address, uint256));
        return DecodedStruct(id, owner, balance);
    }

    function decodeUintArray(bytes memory data) public pure returns (uint256[] memory) {
        require(data.length >= 32, "Data too short");
        return abi.decode(data, (uint256[]));
    }

    function decodeDynamicTypes(bytes memory data) public pure returns (string memory, bytes memory) {
        require(data.length >= 64, "Data too short");
        return abi.decode(data, (string, bytes));
    }

    function decodeTransaction(bytes memory rawTx) public pure returns (DecodedTransaction memory) {
        require(rawTx.length >= 100, "Invalid transaction length");
        address from;
        address to;
        uint256 value;
        uint256 gasLimit;
        uint256 nonce;
        bytes memory txData;
        bytes memory signature;
        assembly {
            from := mload(add(rawTx, 20))
            to := mload(add(rawTx, 40))
            value := mload(add(rawTx, 72))
            gasLimit := mload(add(rawTx, 104))
            nonce := mload(add(rawTx, 136))
            let dataSize := sub(mload(rawTx), 160)
            txData := mload(0x40)
            mstore(0x40, add(txData, add(dataSize, 32)))
            mstore(txData, dataSize)
            mstore(add(txData, 32), mload(add(rawTx, 168)))
            let sigSize := sub(mload(rawTx), add(dataSize, 160))
            signature := mload(0x40)
            mstore(0x40, add(signature, add(sigSize, 32)))
            mstore(signature, sigSize)
            mstore(add(signature, 32), mload(add(rawTx, add(168, dataSize))))
        }
        return DecodedTransaction(from, to, value, gasLimit, nonce, txData, signature);
    }
    

    function decodeKeyValue(bytes32 key, bytes memory value) public pure returns (DecodedKeyValue memory) {
        return DecodedKeyValue(key, value);
    }
    function extractFunctionSelector(bytes memory data) public pure returns (bytes4) {
        require(data.length >= 4, "Data too short");
        bytes4 selector;
        assembly {
            selector := mload(add(data, 32))
        }
        return selector;
    }
    function decodeFunctionCall(bytes memory data) public pure returns (string memory functionName) {
        bytes4 selector = extractFunctionSelector(data);
        return getFunctionNameFromSelector(selector);
    }
    function getFunctionNameFromSelector(bytes4 selector) public pure returns (string memory) {
        if (selector == bytes4(keccak256("transfer(address,uint256)"))) return "transfer(address,uint256)";
        if (selector == bytes4(keccak256("approve(address,uint256)"))) return "approve(address,uint256)";
        if (selector == bytes4(keccak256("mint(address,uint256)"))) return "mint(address,uint256)";
        return "Unknown Function";
    }
    function decodeEventLog(bytes memory data) public pure returns (uint256, address, string memory) {
        require(data.length > 64, "Data too short");
        (uint256 id, address addr, string memory logData) = abi.decode(data, (uint256, address, string));
        return (id, addr, logData);
    }
    function decodeUsingAssembly(bytes memory data) public pure returns (uint256 num) {
        require(data.length >= 32, "Data too short");
        assembly {
            num := mload(add(data, 32))
        }
    }
    function bitwiseOperation(bytes memory data) public pure returns (uint8) {
        require(data.length > 0, "Data too short");
        return uint8(data[0]) & 0x0F;
    }

    // ---------------- Clone Factory Functionality ----------------
    event CloneCreated(address indexed cloneAddress);
    struct CloneMetadata {
        address creator;
        uint256 creationTime;
        bytes bytecode;
    }
    mapping(address => CloneMetadata) public cloneMetadata;
    address[] public cloneAddresses;
    function createClone(bytes memory bytecode) external returns (address) {
        address clone;
        assembly {
            let size := mload(bytecode)
            let ptr := add(bytecode, 0x20)
            clone := create(0, ptr, size)
        }
        require(clone != address(0), "Clone creation failed");
        cloneMetadata[clone] = CloneMetadata({
            creator: msg.sender,
            creationTime: block.timestamp,
            bytecode: bytecode
        });
        cloneAddresses.push(clone);
        emit CloneCreated(clone);
        return clone;
    }
    function getCloneMetadata(address clone) external view returns (CloneMetadata memory) {
        return cloneMetadata[clone];
    }
    function getAllCloneAddresses() external view returns (address[] memory) {
        return cloneAddresses;
    }

    // ---------------- Call Data Execution ----------------
    event Received(address, uint);
    function executeCallData(
        IERC20 token,
        address callTo,
        address approveAddress,
        address contractOutputsToken,
        address recipient,
        uint256 amount,
        uint256 gasLimit,
        bytes memory payload
    )
        external
        payable
        nonReentrant
    {
        uint256 ethAmount = 0;
        if (isETH(token)) {
            require(address(this).balance >= amount, "ETH balance insufficient");
            ethAmount = amount;
        } else {
            require(token.balanceOf(address(this)) >= amount, "ERC20 balance insufficient");
            tokenApprove(token, approveAddress, amount);
        }
        bool success;
        if (gasLimit > 0) {
            (success, ) = callTo.call{ value: ethAmount, gas: gasLimit }(payload);
        } else {
            (success, ) = callTo.call{ value: ethAmount }(payload);
        }
        require(success, "Call execution failed");
        if (contractOutputsToken != address(0)) {
            uint256 outputTokenAmount = IERC20(contractOutputsToken).balanceOf(address(this));
            if (outputTokenAmount > 0) {
                tokenTransfer(IERC20(contractOutputsToken), recipient, outputTokenAmount);
            }
        }
        if (isETH(token)) {
            if (address(this).balance > 0)
                payable(recipient).transfer(address(this).balance);
        } else {
            uint256 tokenBalance = token.balanceOf(address(this));
            if (tokenBalance > 0)
                tokenTransfer(token, recipient, tokenBalance);
        }
    }
    function isETH(IERC20 token) internal pure returns (bool) {
        return address(token) == address(0);
    }
    function tokenApprove(IERC20 token, address spender, uint256 amount) internal {
        token.approve(spender, amount);
    }
    function tokenTransfer(IERC20 token, address to, uint256 amount) internal {
        token.safeTransfer(to, amount);
    }

    // =====================================================
    //            WALLET AND ORACLE DRONE FACTORY
    // =====================================================
    // This section creates one wallet and one oracle at the same time.
    // Each wallet is assigned a unique ID and immediately linked with a new OracleDrone instance.
    event WalletAndOracleCreated(uint256 indexed walletId, address owner, string label, address oracleAddress);

    struct WalletData {
        address owner;
        string label;
        bool frozen;
        uint256 ethBalance;
    }
    mapping(uint256 => WalletData) public wallets;
    mapping(uint256 => address) public walletOracles;
    uint256 public totalMinted;

mapping(address => mapping(string => string)) public labelToOwner;
event WalletCreatedAndOracleDroneInstantiated(uint256 indexed tokenId1, uint256 id1);
event WalletWithUniqueIdCreated(uint256 indexed tokenId1, uint256 id);
event NewWalletCreatedAndOracleDroneInstantiated(uint256 indexed tokenId1, uint256 id);

}


contract CloneWallet is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address payable;

    address public  capsuleController;
    address public  factory;
    address public oracle;
    uint256 public walletId;
    address public oracleDrone;


    struct WalletData {
        address owner;
        string label;
        bool frozen;
        uint256 ethBalance;
    }

    mapping(uint256 => WalletData) public wallets;
    mapping(uint256 => bytes32) private walletPasswords;
    uint256 public totalMinted;

    event WalletCreated(uint256 indexed tokenId, address indexed owner, string label);
    event WalletFrozen(uint256 indexed tokenId);
    event WalletUnfrozen(uint256 indexed tokenId);
    event LabelChanged(uint256 indexed tokenId, string newLabel);
    event ETHDeposited(uint256 indexed tokenId, address indexed from, uint256 amount);
    event ETHWithdrawn(uint256 indexed tokenId, address indexed to, uint256 amount);
    event ERC20Deposited(uint256 indexed tokenId, address indexed token, address indexed from, uint256 amount);
    event ERC20Withdrawn(uint256 indexed tokenId, address indexed token, address indexed to, uint256 amount);
    event ERC721Deposited(uint256 indexed tokenId, address indexed token, address indexed from, uint256 nftId);
    event ERC721Withdrawn(uint256 indexed tokenId, address indexed token, address indexed to, uint256 nftId);
    event OracleDroneUpdated(address indexed newOracleDrone);

    modifier onlyWalletOwner(uint256 tokenId) {
        require(wallets[tokenId].owner == msg.sender, "Not the owner");
        _;
    }

    modifier notFrozen(uint256 tokenId) {
        require(!wallets[tokenId].frozen, "Wallet is frozen");
        _;
    }

    modifier onlyCapsuleController() {
        require(msg.sender == capsuleController, "Not the controller");
        _;
    }

    constructor( address _oracleDrone) {
        require(_oracleDrone != address(0), "Invalid controller");

        oracleDrone = _oracleDrone;
    }

    function createWallet(uint256 tokenId, address owner, string calldata label) external onlyCapsuleController {
        require(wallets[tokenId].owner == address(0), "Wallet already exists");

        wallets[tokenId] = WalletData({
            owner: owner,
            label: label,
            frozen: false,
            ethBalance: 0
        });

        walletId = tokenId;
        totalMinted++;
        emit WalletCreated(tokenId, owner, label);
    }

    function depositETH(uint256 tokenId) external payable notFrozen(tokenId) nonReentrant {
        require(wallets[tokenId].owner != address(0), "Wallet does not exist");
        wallets[tokenId].ethBalance = wallets[tokenId].ethBalance.add(msg.value);
        emit ETHDeposited(tokenId, msg.sender, msg.value);
    }

    function withdrawETH(uint256 tokenId, uint256 amount) external onlyWalletOwner(tokenId) notFrozen(tokenId) nonReentrant {
        require(wallets[tokenId].ethBalance >= amount, "Insufficient balance");
        wallets[tokenId].ethBalance = wallets[tokenId].ethBalance.sub(amount);
        payable(msg.sender).sendValue(amount);
        emit ETHWithdrawn(tokenId, msg.sender, amount);
    }

    function depositERC20(uint256 tokenId, address token, uint256 amount) external notFrozen(tokenId) nonReentrant {
        require(wallets[tokenId].owner != address(0), "Wallet does not exist");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit ERC20Deposited(tokenId, token, msg.sender, amount);
    }

    function withdrawERC20(uint256 tokenId, address token, uint256 amount) external onlyWalletOwner(tokenId) notFrozen(tokenId) nonReentrant {
        require(amount > 0, "Amount must be > 0");
        IERC20(token).safeTransfer(msg.sender, amount);
        emit ERC20Withdrawn(tokenId, token, msg.sender, amount);
    }

    function depositERC721(uint256 tokenId, address token, uint256 nftId) external notFrozen(tokenId) nonReentrant {
        require(wallets[tokenId].owner != address(0), "Wallet does not exist");
        IERC721(token).transferFrom(msg.sender, address(this), nftId);
        emit ERC721Deposited(tokenId, token, msg.sender, nftId);
    }

    function withdrawERC721(uint256 tokenId, address token, uint256 nftId) external onlyWalletOwner(tokenId) notFrozen(tokenId) nonReentrant {
        IERC721(token).transferFrom(address(this), msg.sender, nftId);
        emit ERC721Withdrawn(tokenId, token, msg.sender, nftId);
    }

    function freezeWallet(uint256 tokenId, string calldata password) external onlyWalletOwner(tokenId) nonReentrant {
        wallets[tokenId].frozen = true;
        walletPasswords[tokenId] = keccak256(abi.encodePacked(password));
        emit WalletFrozen(tokenId);
    }

    function unfreezeWallet(uint256 tokenId, string calldata password) external onlyWalletOwner(tokenId) nonReentrant {
        require(walletPasswords[tokenId] == keccak256(abi.encodePacked(password)), "Incorrect password");
        wallets[tokenId].frozen = false;
        delete walletPasswords[tokenId];
        emit WalletUnfrozen(tokenId);
    }

    function updateOracleDrone(address _oracleDrone) external onlyCapsuleController nonReentrant {
        require(_oracleDrone != address(0), "Invalid OracleDrone address");
        oracleDrone = _oracleDrone;
        emit OracleDroneUpdated(_oracleDrone);
    }
}


contract CapsuleLegacyModule {
    struct Legacy {
        address beneficiary;
        uint256 unlockTimestamp;
        bool claimed;
    }

    mapping(uint256 => Legacy) public legacyVaults; // capsuleId => Legacy
    address public capsuleContract;

    event LegacyAssigned(uint256 indexed capsuleId, address indexed beneficiary, uint256 unlockTimestamp);
    event CapsuleClaimed(uint256 indexed capsuleId, address indexed beneficiary);

    modifier onlyCapsuleOwner(uint256 capsuleId) {
        require(msg.sender == ICapsule(capsuleContract).ownerOf(capsuleId), "Not capsule owner");
        _;
    }

    constructor(address _capsuleContract) {
        capsuleContract = _capsuleContract;
    }

    function assignBeneficiary(uint256 capsuleId, address beneficiary, uint256 unlockAfter) external onlyCapsuleOwner(capsuleId) {
        legacyVaults[capsuleId] = Legacy(beneficiary, block.timestamp + unlockAfter, false);
        emit LegacyAssigned(capsuleId, beneficiary, block.timestamp + unlockAfter);
    }

    function claimCapsule(uint256 capsuleId) external {
        Legacy storage legacy = legacyVaults[capsuleId];
        require(msg.sender == legacy.beneficiary, "Not beneficiary");
        require(block.timestamp >= legacy.unlockTimestamp, "Not unlocked yet");
        require(!legacy.claimed, "Already claimed");

        legacy.claimed = true;
        ICapsule(capsuleContract).transferFrom(ICapsule(capsuleContract).ownerOf(capsuleId), msg.sender, capsuleId);

        emit CapsuleClaimed(capsuleId, msg.sender);
    }
}

interface ICapsule {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
}


/// @title CapsuleTimelineModule
/// @notice Supports chaining capsules together into timelines or stories
contract CapsuleTimelineModule {
    struct TimelineEntry {
        uint256 parentId;
        string tag;
    }

    mapping(uint256 => TimelineEntry) public timelines; // capsuleId => TimelineEntry
    address public capsuleContract;

    event TimelineLinked(uint256 indexed capsuleId, uint256 indexed parentId, string tag);

    modifier onlyCapsuleOwner(uint256 capsuleId) {
        require(msg.sender == ICapsule(capsuleContract).ownerOf(capsuleId), "Not capsule owner");
        _;
    }

    constructor(address _capsuleContract) {
        capsuleContract = _capsuleContract;
    }

    function linkToTimeline(uint256 capsuleId, uint256 parentId, string calldata tag) external onlyCapsuleOwner(capsuleId) {
        timelines[capsuleId] = TimelineEntry(parentId, tag);
        emit TimelineLinked(capsuleId, parentId, tag);
    }
}


/// @title CapsulePrivacyModule (Skeleton)
/// @notice Intended for off-chain encrypted content reference
contract CapsulePrivacyModule {
    struct EncryptedCapsule {
        string encryptedUri; // Points to encrypted data (e.g., IPFS)
        address allowedDecryptor;
    }

    mapping(uint256 => EncryptedCapsule) public encryptedVaults; // capsuleId => EncryptedCapsule
    address public capsuleContract;

    event EncryptedCapsuleStored(uint256 indexed capsuleId, string uri, address decryptor);

    modifier onlyCapsuleOwner(uint256 capsuleId) {
        require(msg.sender == ICapsule(capsuleContract).ownerOf(capsuleId), "Not capsule owner");
        _;
    }

    constructor(address _capsuleContract) {
        capsuleContract = _capsuleContract;
    }

    function storeEncryptedCapsule(uint256 capsuleId, string calldata encryptedUri, address decryptor) external onlyCapsuleOwner(capsuleId) {
        encryptedVaults[capsuleId] = EncryptedCapsule(encryptedUri, decryptor);
        emit EncryptedCapsuleStored(capsuleId, encryptedUri, decryptor);
    }

    function getEncryptedUri(uint256 capsuleId) external view returns (string memory) {
        require(msg.sender == encryptedVaults[capsuleId].allowedDecryptor, "Unauthorized");
        return encryptedVaults[capsuleId].encryptedUri;
    }
}

from edalize.vunit_hooks import VUnitHooks
from vunit.verilog import VUnit
from vunit import VUnitCLI
from vunit.ui import Library, Results


class VUnitRunner(VUnitHooks):
    def __init__(self):
        super().__init__()
        self._args = None

    def create(self) -> VUnit:
        cli = VUnitCLI()
        cli.parser.add_argument('--coverage')
        self._args = cli.parse_args()
        vu = VUnit.from_args(args=self._args)
        return vu

    def handle_library(self, logical_name: str, vu_lib: Library):
        if logical_name == 'tb_lib':
            vu_lib.set_sim_option("modelsim.vsim_flags", ["-voptargs=+acc", "-sv_seed random", "-debugdb", "-assertdebug"])
            if self._args.coverage is not None:
                vu_lib.set_sim_option("enable_coverage", True)
        else:
            if self._args.coverage is not None:
                vu_lib.set_compile_option("enable_coverage", True)
                vu_lib.set_compile_option("modelsim.vcom_flags", [f"+cover={self._args.coverage}"])
                vu_lib.set_compile_option("modelsim.vlog_flags", [f"+cover={self._args.coverage}"])

    def main(self, vu: VUnit):
        if self._args.coverage is None:
            vu.main()
        else:
            def post_run_handler(results: Results):
                results.merge_coverage(file_name="merged_coverage.ucdb")
            vu.main(post_run=post_run_handler)